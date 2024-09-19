terraform {
  required_version = "~> 1.5"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.15.0, < 2.0.0"
    }
  }
}
