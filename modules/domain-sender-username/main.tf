resource "azapi_resource" "this" {
  name      = var.name
  parent_id = var.parent_id
  type      = var.resource_types.communication_email_services_domains_sender_usernames
  body = {
    properties = {
      displayName = var.display_name
      username    = var.name
    }
  }
  ignore_body_changes    = length(var.ignore_body_changes.communication_email_services_domains_sender_usernames) > 0 ? var.ignore_body_changes.communication_email_services_domains_sender_usernames : null
  response_export_values = []
  retry                  = var.retry

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
