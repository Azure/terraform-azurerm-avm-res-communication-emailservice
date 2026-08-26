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

mock_provider "azurerm" {}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  name                = "ecs-test"
  location            = "eastus"
  resource_group_name = "rg-test"
  data_location       = "United States"
  enable_telemetry    = false

  email_communication_service_domains = {
    primary = {
      name              = "example.com"
      domain_management = "CustomerManaged"
    }
  }
}

run "domain_resource_ids_output" {
  command = apply

  override_resource {
    target = azapi_resource.email_communication_service_domain["primary"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test/domains/example.com"
    }
  }

  assert {
    condition     = output.domain_resource_ids == { primary = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test/domains/example.com" }
    error_message = "domain_resource_ids should expose the domain resource ID keyed by the same key used in var.email_communication_service_domains."
  }
}
