output "domain_resource_ids" {
  description = "A map of the resource IDs for the deployed Email Communication Service domains, keyed by the same keys as `var.email_communication_service_domains`."
  value       = { for k, v in azapi_resource.email_communication_service_domain : k => v.id }
}

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
