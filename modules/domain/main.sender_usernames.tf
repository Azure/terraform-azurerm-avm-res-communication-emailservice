module "sender_usernames" {
  source   = "./modules/sender_username"
  for_each = var.sender_usernames

  domain_id    = azurerm_email_communication_service_domain.this.id
  name         = each.value.name
  username     = each.value.username
  display_name = each.value.display_name

  depends_on = [
    azurerm_email_communication_service_domain.this
  ]
}
