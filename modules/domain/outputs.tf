output "from_sender_domain" {
  description = "The `fromSenderDomain` value of the Email Communication Service Domain."
  value       = azapi_resource.this.output.from_sender_domain
}

output "mail_from_sender_domain" {
  description = "The `mailFromSenderDomain` value of the Email Communication Service Domain."
  value       = azapi_resource.this.output.mail_from_sender_domain
}

output "name" {
  description = "The name of the Email Communication Service Domain."
  value       = azapi_resource.this.name
}

output "resource_id" {
  description = "The resource ID of the Email Communication Service Domain."
  value       = azapi_resource.this.id
}

output "verification_records" {
  description = "The DNS verification records that must be created for the Email Communication Service Domain. Only populated for customer-managed domains."
  value       = azapi_resource.this.output.verification_records
}

output "verification_states" {
  description = "The verification status of each DNS record type for the Email Communication Service Domain."
  value       = azapi_resource.this.output.verification_states
}
