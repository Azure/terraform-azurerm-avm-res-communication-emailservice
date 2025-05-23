resource "azurerm_resource_group" "this" {
  location = var.location
  name     = var.resource_group_name
  tags     = var.tags
}

resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azapi_resource.email_communication_service.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.email_communication_service.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

resource "azapi_resource" "email_communication_service" {
  type = "Microsoft.Communication/emailServices@2023-03-31"
  body = {
    properties = {
      dataLocation = var.data_location
    }
  }
  location  = "global"
  name      = var.name
  parent_id = azurerm_resource_group.this.id
  tags      = var.email_communication_service_tags
}

resource "azapi_resource" "email_communication_service_domain" {
  for_each = var.email_communication_service_domains

  type = "Microsoft.Communication/emailServices/domains@2023-03-31"
  body = {
    properties = {
      domainManagement       = each.value.domain_management
      userEngagementTracking = each.value.user_engagement_tracking_enabled ? "Enabled" : "Disabled"
    }
  }
  location  = "global"
  name      = each.value.email_communication_service_domain_name
  parent_id = azapi_resource.email_communication_service.id
  tags      = each.value.email_communication_service_domain_tags
}
