output "domain_from_sender_domains" {
  description = "A map of the `fromSenderDomain` values for the deployed Email Communication Service domains, keyed by the same keys as `var.email_communication_service_domains`."
  value       = { for k, v in module.domain : k => v.from_sender_domain }
}

output "domain_mail_from_sender_domains" {
  description = "A map of the `mailFromSenderDomain` values for the deployed Email Communication Service domains, keyed by the same keys as `var.email_communication_service_domains`."
  value       = { for k, v in module.domain : k => v.mail_from_sender_domain }
}

output "domain_resource_ids" {
  description = "A map of the resource IDs for the deployed Email Communication Service domains, keyed by the same keys as `var.email_communication_service_domains`."
  value       = { for k, v in module.domain : k => v.resource_id }
}

output "domain_sender_username_resource_ids" {
  description = "A map of the resource IDs for the deployed Email Communication Service domain sender usernames, keyed by the same keys as `var.email_communication_service_domain_sender_usernames`."
  value       = { for k, v in module.domain_sender_username : k => v.resource_id }
}

output "domain_verification_records" {
  description = "A map of the DNS verification records for the deployed Email Communication Service domains, keyed by the same keys as `var.email_communication_service_domains`."
  value       = { for k, v in module.domain : k => v.verification_records }
}

output "domain_verification_states" {
  description = "A map of the DNS verification states for the deployed Email Communication Service domains, keyed by the same keys as `var.email_communication_service_domains`."
  value       = { for k, v in module.domain : k => v.verification_states }
}

output "name" {
  description = "The name of the email communication service"
  value       = azapi_resource.email_communication_service.name
}

output "resource_id" {
  description = "The resource ID of email communication service"
  value       = azapi_resource.email_communication_service.id
}

output "resource_in_azurerm_schema" {
  description = "The resource of email communication service in azurerm schema"
  value       = local.azurerm_resource_body
}
