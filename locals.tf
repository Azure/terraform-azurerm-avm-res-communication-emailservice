locals {
  azurerm_resource_body = {
    id                  = azapi_resource.email_communication_service.id
    name                = azapi_resource.email_communication_service.name
    resource_group_name = provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id).resource_group_name
    data_location       = azapi_resource.email_communication_service.body.properties.dataLocation
    tags                = azapi_resource.email_communication_service.tags
  }
  # A domain inherits the service tags unless it supplies its own set, which replaces
  # them outright rather than merging.
  domain_tags = {
    for k, v in var.email_communication_service_domains : k => v.tags == null ? var.tags : v.tags
  }
}
