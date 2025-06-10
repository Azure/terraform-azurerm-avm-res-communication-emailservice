data "azapi_resource" "rg" {
  name = var.resource_group_name
  type = "Microsoft.Resources/resourceGroups@2024-11-01"
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
  location  = "global"
  name      = var.name
  parent_id = data.azapi_resource.rg.id
  type      = "Microsoft.Communication/emailServices@2023-03-31"
  body = {
    properties = {
      dataLocation = var.data_location
    }
  }
  create_headers = { "User-Agent" : local.avm_azapi_header }
  delete_headers = { "User-Agent" : local.avm_azapi_header }
  read_headers   = { "User-Agent" : local.avm_azapi_header }
  tags           = var.email_communication_service_tags
  update_headers = { "User-Agent" : local.avm_azapi_header }
}

resource "azapi_resource" "email_communication_service_domain" {
  for_each = var.email_communication_service_domains

  location  = "global"
  name      = each.value.name
  parent_id = azapi_resource.email_communication_service.id
  type      = "Microsoft.Communication/emailServices/domains@2023-03-31"
  body = {
    properties = {
      domainManagement       = each.value.domain_management
      userEngagementTracking = each.value.user_engagement_tracking_enabled ? "Enabled" : "Disabled"
    }
  }
  create_headers = { "User-Agent" : local.avm_azapi_header }
  delete_headers = { "User-Agent" : local.avm_azapi_header }
  read_headers   = { "User-Agent" : local.avm_azapi_header }
  tags           = each.value.tags
  update_headers = { "User-Agent" : local.avm_azapi_header }
}

resource "azapi_resource" "email_communication_service_domain_sender_username" {
  for_each = var.email_communication_service_domain_sender_usernames

  name      = each.value.name
  parent_id = azapi_resource.email_communication_service_domain[each.value.email_communication_service_domain_name_key].id
  type      = "Microsoft.Communication/emailServices/domains/senderUsernames@2023-03-31"
  body = {
    properties = {
      displayName = each.value.display_name
      username    = each.value.name
    }
  }
  create_headers = { "User-Agent" : local.avm_azapi_header }
  delete_headers = { "User-Agent" : local.avm_azapi_header }
  read_headers   = { "User-Agent" : local.avm_azapi_header }
  update_headers = { "User-Agent" : local.avm_azapi_header }
}
