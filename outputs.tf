output "name" {
  description = "Name of the Email Communication Service"
  value       = azurerm_email_communication_service.this.name
}

output "resource_id" {
  description = "The Azure resource id of the Email Communication Service."
  value       = azurerm_email_communication_service.this.id
}
