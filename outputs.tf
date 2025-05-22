output "email_communication_service" {
  description = "The resource of email communication service"
  value       = azapi_resource.emailCommunicationService
}

output "email_communication_service_id" {
  description = "The resource ID of email communication service"
  value       = azapi_resource.emailCommunicationService.id
}
