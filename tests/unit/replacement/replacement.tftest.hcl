# Only the baseline is applied, using mocked providers. All real-AzAPI runs are
# refresh-free plans against that in-memory state. Run via ../replacement.ps1,
# which also checks resource_changes actions in Terraform's verbose JSON.
mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test"
      output                    = {}
      ignore_missing_property   = true
      schema_validation_enabled = true
    }
  }
}

mock_provider "modtm" {}
mock_provider "random" {
  mock_resource "random_uuid" {
    defaults = {
      result = "11111111-1111-4111-8111-111111111111"
    }
  }
}

# Random's planner is also entirely local. It must keep the stored UUIDs when
# immutable role properties change, rather than hiding a keepers-based change.
provider "random" {
  alias = "offline"
}

# The interfaces module does this lookup even when callers supply a full ID.
# Override the data source in ALL runs, including the real-provider plans.
override_data {
  target = module.avm_interfaces.data.azapi_resource_list.role_definitions[0]
  values = {
    output = { results = [] }
  }
}

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

  # Even an unexpected auth or ARM request cannot reach Azure.
  environment = "public"
  endpoint = [{
    active_directory_authority_host = "https://127.0.0.1:1/"
    resource_manager_endpoint       = "https://127.0.0.1:1/"
    resource_manager_audience       = "https://127.0.0.1:1/"
  }]
}

variables {
  name             = "ecs-test"
  location         = "eastus"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  data_location    = "United States"
  enable_telemetry = false

  role_assignments = {
    generated = {
      principal_id                           = "00000000-0000-0000-0000-000000000003"
      role_definition_id_or_name             = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
      principal_type                         = "ServicePrincipal"
      delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/delegated-one"
    }
    explicit = {
      name                                   = "22222222-2222-4222-8222-222222222222"
      principal_id                           = "00000000-0000-0000-0000-000000000003"
      role_definition_id_or_name             = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
      principal_type                         = "ServicePrincipal"
      delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/delegated-one"
    }
  }
}

run "baseline" {
  command = apply

  override_resource {
    target = azapi_resource.role_assignment["generated"]
    values = {
      id                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test/providers/Microsoft.Authorization/roleAssignments/11111111-1111-4111-8111-111111111111"
      output                    = {}
      ignore_missing_property   = true
      schema_validation_enabled = true
      location                  = null
      tags                      = null
      retry = {
        multiplier           = 1.5
        randomization_factor = 0.5
      }
    }
  }

  override_resource {
    target = azapi_resource.role_assignment["explicit"]
    values = {
      id                        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test/providers/Microsoft.Authorization/roleAssignments/22222222-2222-4222-8222-222222222222"
      output                    = {}
      ignore_missing_property   = true
      schema_validation_enabled = true
      location                  = null
      tags                      = null
      retry = {
        multiplier           = 1.5
        randomization_factor = 0.5
      }
    }
  }

  assert {
    condition     = azapi_resource.role_assignment["generated"].name == "11111111-1111-4111-8111-111111111111" && azapi_resource.role_assignment["explicit"].name == "22222222-2222-4222-8222-222222222222"
    error_message = "The baseline must use the cached interfaces module's generated UUID and preserve the caller-supplied GUID."
  }
}

run "service_unchanged" {
  command = plan

  providers = {
    azapi  = azapi.offline
    random = random.offline
  }

  plan_options {
    refresh = false
  }
}

run "service_data_location_changed" {
  command = plan

  providers = {
    azapi  = azapi.offline
    random = random.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    data_location = "Europe"
  }
}

run "roles_principal_changed" {
  command = plan

  providers = {
    azapi  = azapi.offline
    random = random.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    role_assignments = {
      for key, assignment in var.role_assignments : key => merge(assignment, {
        principal_id = "00000000-0000-0000-0000-000000000004"
      })
    }
  }
}

run "roles_definition_changed" {
  command = plan

  providers = {
    azapi  = azapi.offline
    random = random.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    role_assignments = {
      for key, assignment in var.role_assignments : key => merge(assignment, {
        role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      })
    }
  }
}

run "roles_delegated_identity_changed" {
  command = plan

  providers = {
    azapi  = azapi.offline
    random = random.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    role_assignments = {
      for key, assignment in var.role_assignments : key => merge(assignment, {
        delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/delegated-two"
      })
    }
  }
}

run "roles_delegated_identity_removed" {
  command = plan

  providers = {
    azapi  = azapi.offline
    random = random.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    role_assignments = {
      for key, assignment in var.role_assignments : key => merge(assignment, {
        delegated_managed_identity_resource_id = null
      })
    }
  }
}

run "roles_description_changed" {
  command = plan

  providers = {
    azapi  = azapi.offline
    random = random.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    role_assignments = {
      for key, assignment in var.role_assignments : key => merge(assignment, {
        description = "Updated description"
      })
    }
  }
}

run "roles_condition_changed" {
  command = plan

  providers = {
    azapi  = azapi.offline
    random = random.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    role_assignments = {
      for key, assignment in var.role_assignments : key => merge(assignment, {
        condition         = "!(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'})"
        condition_version = "2.0"
      })
    }
  }
}

# An existing generated assignment can be retained by explicitly supplying the
# same GUID, which is also the naming contract needed after a matching import.
# This does not claim to exercise the provider's network-backed import operation.
run "existing_generated_guid_supplied_by_caller" {
  command = plan

  providers = {
    azapi  = azapi.offline
    random = random.offline
  }

  plan_options {
    refresh = false
  }

  variables {
    role_assignments = {
      for key, assignment in var.role_assignments : key => merge(assignment, {
        name = key == "generated" ? "11111111-1111-4111-8111-111111111111" : assignment.name
      })
    }
  }
}
