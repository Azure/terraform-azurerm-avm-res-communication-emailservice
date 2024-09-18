module "domains" {
  source   = "./modules/domain"
  for_each = var.domains

  email_service_id                 = azurerm_email_communication_service.this.id
  name                             = each.value.name
  domain_management                = each.value.domain_management
  user_engagement_tracking_enabled = each.value.user_engagement_tracking_enabled
  lock                             = each.value.lock
  role_assignments                 = each.value.role_assignments
  tags                             = each.value.tags

  depends_on = [
    azurerm_email_communication_service.this
  ]
}
