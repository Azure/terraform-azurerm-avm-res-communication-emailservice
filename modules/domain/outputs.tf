output "name" {
  description = "The name of the domain"
  value       = azurerm_email_communication_service_domain.this.name
}

output "resource_id" {
  description = "The Azure resource id of the domain."
  value       = azurerm_email_communication_service_domain.this.id
}
