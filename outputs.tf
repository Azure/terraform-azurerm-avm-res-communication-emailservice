output "resource" {
  description = "The resource of email communication service"
  value       = azapi_resource.emailCommunicationService
}

output "resource_id" {
  description = "The resource ID of email communication service"
  value       = azapi_resource.emailCommunicationService.id
}
