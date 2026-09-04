mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test/domains/example.com/senderUsernames/donotreply"
    }
  }
}

mock_provider "modtm" {}
mock_provider "random" {}

variables {
  name             = "donotreply"
  parent_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test/domains/example.com"
  enable_telemetry = false
}

run "sender_username_defaults" {
  command = plan

  assert {
    condition     = azapi_resource.this.type == "Microsoft.Communication/emailServices/domains/senderUsernames@2023-03-31"
    error_message = "The sender username should use the default Microsoft.Communication/emailServices/domains/senderUsernames API version."
  }

  assert {
    condition     = azapi_resource.this.body.properties.username == "donotreply"
    error_message = "The `username` property should be derived from `var.name`."
  }
}

run "display_name_is_applied" {
  command = plan

  variables {
    display_name = "Do Not Reply"
  }

  assert {
    condition     = azapi_resource.this.body.properties.displayName == "Do Not Reply"
    error_message = "The `displayName` property should be set from `var.display_name`."
  }
}
