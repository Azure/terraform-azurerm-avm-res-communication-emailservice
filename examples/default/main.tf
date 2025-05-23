terraform {
  required_version = "~> 1.11"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.29"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "azurerm" {
  features {}
}

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

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4"
}

resource "random_string" "name_suffix" {
  length  = 5
  lower   = true
  numeric = false
  special = false
  upper   = true
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  data_location = "United States"
  # source              = "Azure/avm-res-communication-emailservice"
  location            = module.regions.regions[random_integer.region_index.result].name
  name                = "email-communication-service-${random_string.name_suffix.id}"
  resource_group_name = module.naming.resource_group.name_unique

  email_communication_service_domains = {
    "azureManagedDomain" = {
      email_communication_service_domain_name = "AzureManagedDomain"
      domain_management                       = "AzureManaged"
    }

    "customerManagedDomain" = {
      email_communication_service_domain_name = "example.com"
      domain_management                       = "CustomerManaged"
      user_engagement_tracking_enabled        = true

      email_communication_service_domain_tags = {
        env = "Test"
      }
    }
  }

  email_communication_service_domain_sender_usernames = {
    "azureManagedDomainSenderUsername" = {
      email_communication_service_domain_sender_username = "azureManagedDomain-sender-username-${random_string.name_suffix.id}"
      email_communication_service_domain_name_key        = "azureManagedDomain"
      display_name                                       = "TFTester"
    }

    "customerManagedDomainSenderUsername" = {
      email_communication_service_domain_sender_username = "customerManagedDomain-sender-username-${random_string.name_suffix.id}"
      email_communication_service_domain_name_key        = "customerManagedDomain"
    }
  }

  enable_telemetry = var.enable_telemetry # see variables.tf
}
