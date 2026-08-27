data "azapi_resource" "rg" {
  name                   = var.resource_group_name
  type                   = "Microsoft.Resources/resourceGroups@2024-11-01"
  response_export_values = []
}

resource "azapi_resource" "email_communication_service" {
  location  = "global"
  name      = var.name
  parent_id = data.azapi_resource.rg.id
  type      = var.resource_types.communication_email_services
  body = {
    properties = {
      dataLocation = var.data_location
    }
  }
  create_headers      = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers      = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_body_changes = length(var.ignore_body_changes.communication_email_services) > 0 ? var.ignore_body_changes.communication_email_services : null
  read_headers        = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  # `dataLocation` is immutable, so a change to it must replace the service.
  replace_triggers_refs  = ["body.properties.dataLocation"]
  response_export_values = []
  retry                  = var.retry
  tags                   = var.tags
  update_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

module "domain" {
  source   = "./modules/domain"
  for_each = var.email_communication_service_domains

  domain_management                = each.value.domain_management
  name                             = each.value.name
  parent_id                        = azapi_resource.email_communication_service.id
  enable_telemetry                 = var.enable_telemetry
  ignore_body_changes              = var.ignore_body_changes.communication_email_services_domains
  resource_types                   = var.resource_types.communication_email_services_domains
  retry                            = var.retry
  tags                             = local.domain_tags[each.key]
  timeouts                         = var.timeouts
  user_engagement_tracking_enabled = each.value.user_engagement_tracking_enabled
}

module "domain_sender_username" {
  source   = "./modules/domain-sender-username"
  for_each = var.email_communication_service_domain_sender_usernames

  name                = each.value.name
  parent_id           = module.domain[each.value.email_communication_service_domain_name_key].resource_id
  display_name        = each.value.display_name
  enable_telemetry    = var.enable_telemetry
  ignore_body_changes = var.ignore_body_changes.communication_email_services_domains_sender_usernames
  resource_types      = var.resource_types.communication_email_services_domains_sender_usernames
  retry               = var.retry
  timeouts            = var.timeouts
}
