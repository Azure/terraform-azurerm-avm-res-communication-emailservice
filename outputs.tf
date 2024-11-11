output "domains" {
  description = "A map of domains."
  value = { for dk, dv in module.domains : dk => {
    name                    = dv.name
    mail_from_sender_domain = dv.mail_from_sender_domain
    from_sender_domain      = dv.from_sender_domain
    resource_id             = dv.resource_id
    verification_records    = dv.verification_records
    }
  }
}

output "name" {
  description = "Name of the Email Communication Service."
  value       = azurerm_email_communication_service.this.name
}

output "resource_id" {
  description = "The Azure resource id of the Email Communication Service."
  value       = azurerm_email_communication_service.this.id
}
