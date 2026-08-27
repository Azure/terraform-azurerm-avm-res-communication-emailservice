module "avm_interfaces" {
  source  = "Azure/avm-utl-interfaces/azure"
  version = "0.7.0"

  enable_telemetry                 = var.enable_telemetry
  lock                             = var.lock
  role_assignment_definition_scope = azapi_resource.email_communication_service.id
  role_assignments                 = var.role_assignments
}

resource "azapi_resource" "lock" {
  for_each = module.avm_interfaces.lock_azapi == null ? {} : { lock = module.avm_interfaces.lock_azapi }

  name                   = coalesce(each.value.name, "lock-${var.lock.kind}")
  parent_id              = azapi_resource.email_communication_service.id
  type                   = var.resource_types.authorization_locks
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_body_changes    = length(var.ignore_body_changes.authorization_locks) > 0 ? var.ignore_body_changes.authorization_locks : null
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  retry                  = var.retry
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

  depends_on = [azapi_resource.role_assignment]
}

resource "azapi_resource" "role_assignment" {
  for_each = module.avm_interfaces.role_assignments_azapi

  name                   = each.value.name
  parent_id              = azapi_resource.email_communication_service.id
  type                   = var.resource_types.authorization_role_assignments
  body                   = each.value.body
  create_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers         = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  ignore_body_changes    = length(var.ignore_body_changes.authorization_role_assignments) > 0 ? var.ignore_body_changes.authorization_role_assignments : null
  ignore_null_property   = true
  read_headers           = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  response_export_values = []
  # Role assignments frequently fail immediately after the scope is created because
  # the principal or the scope has not replicated yet.
  retry = var.retry != null ? var.retry : {
    error_message_regex  = tolist(["ScopeLocked", "PrincipalNotFound", "ResourceNotFound"])
    interval_seconds     = 15
    max_interval_seconds = 60
  }
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

  lifecycle {
    # `principalType` is resolved server-side when it is not supplied, which would
    # otherwise show as permanent drift.
    ignore_changes = [body.properties.principalType]
  }
}
