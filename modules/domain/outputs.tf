output "from_sender_domain" {
  description = "P2 sender domain that is displayed to the email recipients [RFC 5322]."
  value       = azurerm_email_communication_service_domain.this.from_sender_domain
}

output "mail_from_sender_domain" {
  description = "P1 sender domain that is present on the email envelope [RFC 5321]."
  value       = azurerm_email_communication_service_domain.this.mail_from_sender_domain
}

output "name" {
  description = "The name of the domain"
  value       = azurerm_email_communication_service_domain.this.name
}

output "resource_id" {
  description = "The Azure resource id of the domain."
  value       = azurerm_email_communication_service_domain.this.id
}

output "verification_records" {
  description = "Verification records for the domain."
  value       = azurerm_email_communication_service_domain.this.verification_records
}
