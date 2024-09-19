output "name" {
  description = "The name of the sender username."
  value       = azapi_resource.sender_username.name
}

output "resource_id" {
  description = "The Azure resource id of the sender username."
  value       = azapi_resource.sender_username.id
}
