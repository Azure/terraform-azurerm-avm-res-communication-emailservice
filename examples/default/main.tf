## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.5"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

resource "random_string" "name_suffix" {
  length  = 5
  lower   = true
  numeric = false
  special = false
  upper   = true
}

resource "azapi_resource" "resource_group" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = "avm-res-communication-emailservice-${random_string.name_suffix.result}"
  type     = "Microsoft.Resources/resourceGroups@2024-11-01"
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  data_location = "United States"
  # source              = "Azure/avm-res-communication-emailservice"
  location            = azapi_resource.resource_group.location
  name                = "email-communication-service-${random_string.name_suffix.id}"
  resource_group_name = azapi_resource.resource_group.name
  email_communication_service_domain_sender_usernames = {
    azureManagedDomainSenderUsername = {
      name                                        = "azureManagedDomain-sender-username-${random_string.name_suffix.id}"
      email_communication_service_domain_name_key = "azureManagedDomain"
      display_name                                = "TFTester"
    }

    customerManagedDomainSenderUsername = {
      name                                        = "customerManagedDomain-sender-username-${random_string.name_suffix.id}"
      email_communication_service_domain_name_key = "customerManagedDomain"
    }
  }
  email_communication_service_domains = {
    azureManagedDomain = {
      name              = "AzureManagedDomain"
      domain_management = "AzureManaged"
    }

    customerManagedDomain = {
      name                             = "example.com"
      domain_management                = "CustomerManaged"
      user_engagement_tracking_enabled = true

      tags = {
        env = "Test"
      }
    }
  }
  enable_telemetry = var.enable_telemetry # see variables.tf

  depends_on = [azapi_resource.resource_group]
}
