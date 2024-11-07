resource "azapi_resource" "sender_username" {
  type = "Microsoft.Communication/emailServices/domains/senderUsernames@2023-04-01"
  body = {
    properties = {
      username    = var.username
      displayName = local.display_name
    }
  }
  parent_id                 = var.domain_id
  name                      = var.name
  schema_validation_enabled = true
}
