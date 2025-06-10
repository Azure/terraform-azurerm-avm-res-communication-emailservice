output "resource" {
  description = "The resource of email communication service"
  value       = azapi_resource.email_communication_service
}

output "resource_id" {
  description = "The resource ID of email communication service"
  value       = azapi_resource.email_communication_service.id
}

output "resource_in_azurerm_schema" {
  description = "The resource of email communication service in azurerm schema"
  value       = local.azurerm_resource_body
}
