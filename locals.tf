locals {
  azurerm_resource_body = {
    id                  = azapi_resource.email_communication_service.id
    name                = azapi_resource.email_communication_service.name
    resource_group_name = data.azapi_resource.rg.name
    data_location       = azapi_resource.email_communication_service.body.properties.dataLocation
    tags                = azapi_resource.email_communication_service.tags
  }
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}
