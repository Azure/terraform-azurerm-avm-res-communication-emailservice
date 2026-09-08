mock_provider "azapi" {
  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test/domains/example.com"
      output = {
        from_sender_domain      = "example.com"
        mail_from_sender_domain = "example.com"
        verification_records    = {}
        verification_states     = {}
      }
    }
  }
}

mock_provider "modtm" {}
mock_provider "random" {}

variables {
  name              = "example.com"
  domain_management = "CustomerManaged"
  parent_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Communication/emailServices/ecs-test"
  enable_telemetry  = false
}

run "domain_defaults" {
  command = plan

  assert {
    condition     = azapi_resource.this.type == "Microsoft.Communication/emailServices/domains@2023-03-31"
    error_message = "The domain should use the default Microsoft.Communication/emailServices/domains API version."
  }

  assert {
    condition     = azapi_resource.this.location == "global"
    error_message = "Email Communication Service Domains are always deployed to the `global` location."
  }

  assert {
    condition     = azapi_resource.this.body.properties.userEngagementTracking == "Disabled"
    error_message = "User engagement tracking should be disabled by default."
  }
}

run "user_engagement_tracking_can_be_enabled" {
  command = plan

  variables {
    user_engagement_tracking_enabled = true
  }

  assert {
    condition     = azapi_resource.this.body.properties.userEngagementTracking == "Enabled"
    error_message = "Setting `user_engagement_tracking_enabled` should enable user engagement tracking."
  }
}

run "tags_are_applied" {
  command = plan

  variables {
    tags = {
      env = "Test"
    }
  }

  assert {
    condition     = azapi_resource.this.tags == tomap({ env = "Test" })
    error_message = "The domain should be tagged with the supplied tags."
  }
}

run "domain_management_replacement_reference" {
  command = apply

  assert {
    condition     = azapi_resource.this.replace_triggers_refs == tolist(["properties.domainManagement"])
    error_message = "Domain replacement references must start at properties, relative to body; body.properties.domainManagement selects nothing."
  }
}
