# Requires the module and provider caches to have been initialized already.
# No init, apply, import, refresh, Azure login, or external endpoint is invoked.
# Terraform test applies only mocked baselines; real providers only plan.
[CmdletBinding()]
param(
    [string] $ModuleRoot = (Join-Path $PSScriptRoot '../..')
)

$ErrorActionPreference = 'Stop'
$ModuleRoot = (Resolve-Path $ModuleRoot).Path
$terraform = (Get-Command terraform -CommandType Application).Source

function Invoke-OfflineTest {
    param([string] $Path, [int] $ExpectedRuns)

    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $terraform
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    foreach ($argument in @("-chdir=$Path", 'test', '-test-directory=tests/unit/replacement', '-json', '-verbose', '-no-color')) {
        $start.ArgumentList.Add($argument)
    }

    # Remove inherited credential/file paths and Terraform CLI overrides from the
    # CHILD environment without reading or changing the caller's credentials.
    foreach ($name in @($start.Environment.Keys)) {
        if ($name -match '^(ARM_|AZURE_|TF_|ACTIONS_ID_TOKEN_|SYSTEM_ACCESSTOKEN$|SYSTEM_OIDCREQUESTURI$)') {
            $null = $start.Environment.Remove($name)
        }
    }
    $start.Environment['TF_IN_AUTOMATION'] = 'true'
    $start.Environment['CHECKPOINT_DISABLE'] = '1'
    # Fail closed if future fixture changes accidentally introduce an HTTP call.
    foreach ($name in @('HTTP_PROXY', 'HTTPS_PROXY', 'ALL_PROXY')) {
        $start.Environment[$name] = 'http://127.0.0.1:1'
    }
    $start.Environment['NO_PROXY'] = '127.0.0.1,localhost'

    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $start
    try {
        $null = $process.Start()
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit(120000)) {
            Stop-Process -Id $process.Id -Force
            throw "Offline Terraform tests timed out in $Path."
        }
        $events = @(
            $stdout.GetAwaiter().GetResult() -split '\r?\n' |
                Where-Object { $_.Length -gt 0 } |
                ForEach-Object { $_ | ConvertFrom-Json -Depth 100 }
        )
        $errors = @($events | Where-Object { $_.type -eq 'diagnostic' -and $_.diagnostic.severity -eq 'error' })
        $summary = @($events | Where-Object type -EQ 'test_summary')
        if ($process.ExitCode -ne 0 -or $errors.Count -gt 0 -or $summary.Count -ne 1 -or
            $summary[0].test_summary.status -ne 'pass' -or $summary[0].test_summary.passed -ne $ExpectedRuns) {
            $details = $errors | ForEach-Object { "$($_.diagnostic.summary): $($_.diagnostic.detail)" }
            throw "Terraform tests failed in $Path.`n$($details -join "`n")`n$($stderr.GetAwaiter().GetResult())"
        }

        $plans = @{}
        foreach ($event in $events | Where-Object type -EQ 'test_plan') {
            $plans[$event.'@testrun'] = $event.test_plan
        }
        if ($plans.Count -ne ($ExpectedRuns - 1)) {
            throw "Expected one mocked baseline and $($ExpectedRuns - 1) real-provider plans in $Path; found $($plans.Count) plans."
        }
        Write-Host "$Path : $ExpectedRuns Terraform runs passed."
        return $plans
    }
    finally {
        $process.Dispose()
    }
}

$failures = [System.Collections.Generic.List[string]]::new()
$counts = @{ Actions = 0; Names = 0; Values = 0 }

function Assert-Actions {
    param($Plans, [string] $Run, [string] $Address, [string] $Expected)

    $change = @($Plans[$Run].resource_changes | Where-Object address -EQ $Address)
    $actual = if ($change.Count -eq 1) { $change[0].change.actions -join ',' } else { '<missing or duplicate>' }
    $counts.Actions++
    if ($actual -ne $Expected) {
        $failures.Add("$Run / $Address : expected [$Expected], got [$actual].")
    }
    return $change[0].change
}

function Assert-ValueChange {
    param($Change, [string] $Property, $Before, $After, [string] $Label)

    $counts.Values++
    if ($Change.before.body.properties.$Property -cne $Before -or $Change.after.body.properties.$Property -cne $After) {
        $failures.Add("$Label : expected body.properties.$Property to change from '$Before' to '$After'.")
    }
}

$root = Invoke-OfflineTest -Path $ModuleRoot -ExpectedRuns 10
$domain = Invoke-OfflineTest -Path (Join-Path $ModuleRoot 'modules/domain') -ExpectedRuns 4

# Each plan starts from the SAME mocked baseline; a plan does not advance state.
$roleActions = [ordered]@{
    service_unchanged                        = 'no-op'
    service_data_location_changed            = 'delete,create'
    roles_principal_changed                  = 'delete,create'
    roles_definition_changed                 = 'delete,create'
    roles_delegated_identity_changed          = 'delete,create'
    roles_delegated_identity_removed          = 'delete,create'
    roles_description_changed                = 'update'
    roles_condition_changed                  = 'update'
    existing_generated_guid_supplied_by_caller = 'no-op'
}
$names = @{
    generated = '11111111-1111-4111-8111-111111111111'
    explicit  = '22222222-2222-4222-8222-222222222222'
}
$subscription = '/subscriptions/00000000-0000-0000-0000-000000000000'
$definitionPrefix = "$subscription/providers/Microsoft.Authorization/roleDefinitions"
$identityPrefix = "$subscription/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities"

foreach ($run in $roleActions.Keys) {
    $serviceAction = if ($run -eq 'service_data_location_changed') { 'delete,create' } else { 'no-op' }
    $service = Assert-Actions $root $run 'azapi_resource.email_communication_service' $serviceAction
    if ($run -eq 'service_data_location_changed') {
        Assert-ValueChange $service 'dataLocation' 'United States' 'Europe' $run
    }

    foreach ($key in @('generated', 'explicit')) {
        $assignment = Assert-Actions $root $run "azapi_resource.role_assignment[`"$key`"]" $roleActions[$run]
        $null = Assert-Actions $root $run "module.avm_interfaces.random_uuid.role_assignment_name[`"$key`"]" 'no-op'
        $counts.Names++
        if ($assignment.before.name -cne $names[$key] -or $assignment.after.name -cne $names[$key]) {
            $failures.Add("$run / $key : both before and after must retain GUID $($names[$key]).")
        }
        switch ($run) {
            'roles_principal_changed' {
                Assert-ValueChange $assignment 'principalId' '00000000-0000-0000-0000-000000000003' '00000000-0000-0000-0000-000000000004' "$run / $key"
            }
            'roles_definition_changed' {
                Assert-ValueChange $assignment 'roleDefinitionId' "$definitionPrefix/acdd72a7-3385-48ef-bd42-f606fba81ae7" "$definitionPrefix/b24988ac-6180-42a0-ab88-20f7382dd24c" "$run / $key"
            }
            'roles_delegated_identity_changed' {
                Assert-ValueChange $assignment 'delegatedManagedIdentityResourceId' "$identityPrefix/delegated-one" "$identityPrefix/delegated-two" "$run / $key"
            }
            'roles_delegated_identity_removed' {
                Assert-ValueChange $assignment 'delegatedManagedIdentityResourceId' "$identityPrefix/delegated-one" $null "$run / $key"
            }
            'roles_description_changed' {
                Assert-ValueChange $assignment 'description' $null 'Updated description' "$run / $key"
            }
            'roles_condition_changed' {
                Assert-ValueChange $assignment 'condition' $null "!(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'})" "$run / $key"
                Assert-ValueChange $assignment 'conditionVersion' $null '2.0' "$run / $key"
            }
        }
    }
}

$null = Assert-Actions $domain 'domain_unchanged' 'azapi_resource.this' 'no-op'
$change = Assert-Actions $domain 'domain_management_changed' 'azapi_resource.this' 'delete,create'
Assert-ValueChange $change 'domainManagement' 'CustomerManaged' 'AzureManaged' 'domain_management_changed'
$change = Assert-Actions $domain 'domain_engagement_changed' 'azapi_resource.this' 'update'
Assert-ValueChange $change 'userEngagementTracking' 'Disabled' 'Enabled' 'domain_engagement_changed'

if ($failures.Count -gt 0) {
    throw "$($failures.Count) regression assertion(s) failed:`n$($failures -join "`n")"
}
Write-Host "PASS: $($counts.Actions) resource-action assertions, $($counts.Names) GUID-preservation assertions, $($counts.Values) body-value assertions. Real AzAPI/Random plans only; all apply/cleanup operations mocked."
