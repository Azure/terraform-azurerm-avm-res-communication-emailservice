# Baseline apply is mocked; subsequent runs use only AzAPI's local planner.
# Invoke tests/unit/replacement.ps1 at the repository root to check plan actions.
mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test/domains/example.com"
      ignore_missing_property   = true
      schema_validation_enabled = true
      output = {
        from_sender_domain      = "example.com"
        mail_from_sender_domain = "example.com"
        verification_records    = {}
        verification_states     = {}
      }
    }
  }
}

mock_provider "modtm" {}
mock_provider "random" {}

provider "azapi" {
  alias = "offline"

  subscription_id            = "00000000-0000-0000-0000-000000000000"
  tenant_id                  = "00000000-0000-0000-0000-000000000001"
  client_id                  = "00000000-0000-0000-0000-000000000002"
  client_secret              = "offline-test-not-a-credential"
  use_cli                    = false
  use_msi                    = false
  use_oidc                   = false
  use_aks_workload_identity  = false
  enable_preflight           = false
  skip_provider_registration = true
  disable_default_output     = true
  disable_instance_discovery = true
  ignore_no_op_changes       = false

  environment = "public"
  endpoint = [{
    active_directory_authority_host = "https://127.0.0.1:1/"
    resource_manager_endpoint       = "https://127.0.0.1:1/"
    resource_manager_audience       = "https://127.0.0.1:1/"
  }]
}

variables {
  name              = "example.com"
  domain_management = "CustomerManaged"
  parent_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test"
  enable_telemetry  = false
}

run "baseline" {
  command = apply
}

run "domain_unchanged" {
  command = plan

  providers = {
    azapi = azapi.offline
  }

  plan_options {
    refresh = false
  }
}

run "domain_management_changed" {
  command = plan

  providers = {
    azapi = azapi.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    domain_management = "AzureManaged"
  }
}

run "domain_engagement_changed" {
  command = plan

  providers = {
    azapi = azapi.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    user_engagement_tracking_enabled = true
  }
}
