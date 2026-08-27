resource "azapi_resource" "this" {
  location  = "global"
  name      = var.name
  parent_id = var.parent_id
  type      = var.resource_types.communication_email_services_domains
  body = {
    properties = {
      domainManagement       = var.domain_management
      userEngagementTracking = var.user_engagement_tracking_enabled ? "Enabled" : "Disabled"
    }
  }
  create_headers      = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers      = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_body_changes = length(var.ignore_body_changes.communication_email_services_domains) > 0 ? var.ignore_body_changes.communication_email_services_domains : null
  read_headers        = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  # `domainManagement` cannot be changed in place, so a change must replace the domain.
  replace_triggers_refs = ["body.properties.domainManagement"]
  response_export_values = {
    from_sender_domain      = "properties.fromSenderDomain"
    mail_from_sender_domain = "properties.mailFromSenderDomain"
    verification_records    = "properties.verificationRecords"
    verification_states     = "properties.verificationStates"
  }
  retry          = var.retry
  tags           = var.tags
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

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
