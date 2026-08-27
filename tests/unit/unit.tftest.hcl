mock_provider "azapi" {
  mock_data "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
    }
  }

  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test"
    }
  }
}

mock_provider "modtm" {}
mock_provider "random" {}

variables {
  name                = "ecs-test"
  location            = "eastus"
  resource_group_name = "rg-test"
  data_location       = "United States"
  enable_telemetry    = false

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
