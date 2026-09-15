output "email_service_name" {
  value = "email-rbac-${random_string.suffix.result}"
}

output "location" {
  value = azapi_resource.resource_group.location
}

output "parent_id" {
  value = azapi_resource.resource_group.id
}

output "principal_ids" {
  value = { for key, identity in azapi_resource.identity : key => identity.output.principal_id }
}

# Distinct roles prevent duplicate principal/role/scope tuples when the two principals are exchanged.
output "role_assignments" {
  value = {
    generated = {
      principal_id               = azapi_resource.identity["first"].output.principal_id
      principal_type             = "ServicePrincipal"
      role_definition_id_or_name = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
    }
    explicit = {
      name                       = random_uuid.explicit_assignment.result
      principal_id               = azapi_resource.identity["second"].output.principal_id
      principal_type             = "ServicePrincipal"
      role_definition_id_or_name = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    }
  }
}

output "replacement_role_ids" {
  value = {
    generated = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
    explicit  = "/subscriptions/${data.azapi_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa"
  }
}
