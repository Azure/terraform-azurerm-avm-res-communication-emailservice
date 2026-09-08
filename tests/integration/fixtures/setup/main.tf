data "azapi_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 10
  special = false
  upper   = false
}

resource "random_uuid" "explicit_assignment" {}

resource "azapi_resource" "resource_group" {
  type                   = "Microsoft.Resources/resourceGroups@2024-11-01"
  name                   = "rg-email-rbac-${random_string.suffix.result}"
  parent_id              = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  location               = "eastus"
  response_export_values = []
}

resource "azapi_resource" "identity" {
  for_each = toset(["first", "second"])

  type      = "Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30"
  name      = "id-email-rbac-${each.key}-${random_string.suffix.result}"
  parent_id = azapi_resource.resource_group.id
  location  = azapi_resource.resource_group.location
  body      = {}
  response_export_values = {
    principal_id = "properties.principalId"
  }
}
