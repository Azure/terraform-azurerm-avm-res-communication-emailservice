terraform {
  required_version = "~> 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
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
  version = "~> 0.1"
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
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

data "azurerm_client_config" "current" {}

resource "random_pet" "pet" {}

# This is the module call
module "test" {
  source        = "../../"
  name          = "emailsvc-${random_pet.pet.id}"
  data_location = "United States"
  lock = {
    kind = "CanNotDelete"
    name = "CanNotDelete-lock"
  }
  role_assignments = {
    deployment_user_reader = {
      role_definition_id_or_name = "Reader"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }
  tags = {
    "hidden-title" = "This is visible in the resource name"
    Env            = "test"
  }

  domains = {
    domain0 = {
      name                             = "AzureManagedDomain"
      domain_management                = "AzureManaged"
      user_engagement_tracking_enabled = true
      lock = {
        kind = "CanNotDelete"
      }
      role_assignments = {
        deployment_user_reader = {
          role_definition_id_or_name = "Reader"
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
      tags = {
        Role = "DeploymentValidation"
      }
    }
  }

  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry # see variables.tf
}
