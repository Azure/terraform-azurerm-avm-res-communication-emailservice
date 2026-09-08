mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test"
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

variables {
  name             = "ecs-test"
  location         = "eastus"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  data_location    = "United States"
  enable_telemetry = false

  tags = {
    env = "Prod"
  }

  email_communication_service_domains = {
    primary = {
      name              = "example.com"
      domain_management = "CustomerManaged"
    }

    secondary = {
      name              = "example.net"
      domain_management = "CustomerManaged"

      tags = {
        env = "Test"
      }
    }
  }
}

run "domain_resource_ids_output" {
  command = apply

  override_module {
    target = module.domain["primary"]
    outputs = {
      resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test/domains/example.com"
    }
  }

  override_module {
    target = module.domain["secondary"]
    outputs = {
      resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test/domains/example.net"
    }
  }

  assert {
    condition     = output.domain_resource_ids["primary"] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test/domains/example.com"
    error_message = "domain_resource_ids should expose the domain resource ID keyed by the same key used in var.email_communication_service_domains."
  }
}

run "domain_tags_inherit_from_service" {
  command = plan

  assert {
    condition     = local.domain_tags["primary"] == tomap({ env = "Prod" })
    error_message = "A domain without its own tags should inherit the tags of the Email Communication Service."
  }
}

run "domain_tags_override_replaces_service_tags" {
  command = plan

  assert {
    condition     = local.domain_tags["secondary"] == tomap({ env = "Test" })
    error_message = "A domain with its own tags should replace, not merge with, the tags of the Email Communication Service."
  }
}

run "lock_is_not_created_by_default" {
  command = plan

  assert {
    condition     = length(azapi_resource.lock) == 0
    error_message = "No management lock should be created when var.lock is null."
  }
}

run "lock_is_created_when_requested" {
  command = plan

  variables {
    lock = {
      kind = "CanNotDelete"
    }
  }

  assert {
    condition     = azapi_resource.lock["lock"].name == "lock-CanNotDelete"
    error_message = "The lock name should default to `lock-<kind>` when no name is supplied."
  }

  assert {
    condition     = azapi_resource.lock["lock"].type == "Microsoft.Authorization/locks@2020-05-01"
    error_message = "The lock should be created with the Microsoft.Authorization/locks resource type."
  }
}

run "resource_types_can_be_overridden" {
  command = plan

  variables {
    resource_types = {
      communication_email_services = "Microsoft.Communication/emailServices@2023-04-01-preview"
    }
  }

  assert {
    condition     = azapi_resource.email_communication_service.type == "Microsoft.Communication/emailServices@2023-04-01-preview"
    error_message = "var.resource_types should control the API version used for the Email Communication Service."
  }
}

run "resource_group_name_is_parsed_from_parent_id" {
  command = plan

  assert {
    condition     = local.azurerm_resource_body.resource_group_name == "rg-test"
    error_message = "The resource group name exposed for AzureRM schema compatibility should be parsed from var.parent_id."
  }
}

run "parent_id_rejects_a_non_resource_group_id" {
  command = plan

  variables {
    parent_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  }

  expect_failures = [var.parent_id]
}

run "immutable_references_and_role_names" {
  command = apply

  variables {
    email_communication_service_domains = {}
    role_assignments = {
      generated = {
        principal_id               = "00000000-0000-0000-0000-000000000003"
        role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
      }
      explicit = {
        name                       = "22222222-2222-4222-8222-222222222222"
        principal_id               = "00000000-0000-0000-0000-000000000003"
        role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
      }
    }
  }

  override_data {
    target = module.avm_interfaces.data.azapi_resource_list.role_definitions[0]
    values = {
      output = { results = [] }
    }
  }

  assert {
    condition     = azapi_resource.email_communication_service.replace_triggers_refs == tolist(["properties.dataLocation"])
    error_message = "Service replacement references must start at properties, relative to body; body.properties.dataLocation selects nothing."
  }

  assert {
    condition = alltrue([
      for assignment in azapi_resource.role_assignment : assignment.replace_triggers_refs == tolist([
        "properties.principalId",
        "properties.roleDefinitionId",
        "properties.delegatedManagedIdentityResourceId",
      ])
    ])
    error_message = "All immutable role fields must trigger replacement; description and condition must remain mutable."
  }

  assert {
    condition     = azapi_resource.role_assignment["generated"].name == "11111111-1111-4111-8111-111111111111"
    error_message = "An omitted name must retain the GUID generated by the interfaces module."
  }

  assert {
    condition     = azapi_resource.role_assignment["explicit"].name == "22222222-2222-4222-8222-222222222222"
    error_message = "A caller-supplied role assignment GUID must be preserved."
  }
}
