# CI OIDC identity needs subscription-scoped RG creation/deletion and permission to manage email services and user-assigned identities.
# It also needs Microsoft.Authorization/roleDefinitions/read and roleAssignments/read,write,delete on the test resource group (Owner, or Contributor plus RBAC Administrator with appropriate conditions).
# Terraform test destroys the root module before its setup state, including on assertion failure; no manual state operations or cleanup hook are needed.

provider "azapi" {
  use_oidc = true
  use_cli  = false
}

variables {
  data_location    = "United States"
  enable_telemetry = false
}

run "setup" {
  command = apply

  module {
    source = "./tests/integration/fixtures/setup"
  }
}

run "create_assignments" {
  command = apply

  variables {
    name             = run.setup.email_service_name
    location         = run.setup.location
    parent_id        = run.setup.parent_id
    role_assignments = run.setup.role_assignments
  }
}

run "read_initial_assignments" {
  command = apply

  module {
    source = "./tests/integration/fixtures/readback"
  }

  variables {
    parent_id     = run.create_assignments.resource_id
    explicit_name = run.setup.role_assignments.explicit.name
  }

  assert {
    condition = alltrue([
      for key, assignment in output.assignments :
      lower(assignment.principal_id) == lower(run.setup.role_assignments[key].principal_id) &&
      lower(assignment.role_definition_id) == lower(run.setup.role_assignments[key].role_definition_id_or_name)
    ])
    error_message = "Azure must return the two initial principals and role definitions before replacement is tested."
  }
}

run "replace_principals" {
  command = apply

  variables {
    name      = run.setup.email_service_name
    location  = run.setup.location
    parent_id = run.setup.parent_id
    role_assignments = {
      for key, assignment in run.setup.role_assignments : key => merge(assignment, {
        principal_id = run.setup.principal_ids[key == "generated" ? "second" : "first"]
      })
    }
  }

  assert {
    condition = alltrue([
      for key, assignment in azapi_resource.role_assignment :
      assignment.name == run.read_initial_assignments.assignments[key].name
    ])
    error_message = "Principal replacement must reuse both assignment GUIDs, not silently generate new names."
  }
}

run "read_replaced_principals" {
  command = apply

  module {
    source = "./tests/integration/fixtures/readback"
  }

  variables {
    parent_id     = run.replace_principals.resource_id
    explicit_name = run.setup.role_assignments.explicit.name
  }

  assert {
    condition = alltrue([
      for key, assignment in output.assignments :
      assignment.name == run.read_initial_assignments.assignments[key].name &&
      lower(assignment.principal_id) == lower(run.setup.principal_ids[key == "generated" ? "second" : "first"]) &&
      lower(assignment.role_definition_id) == lower(run.setup.role_assignments[key].role_definition_id_or_name)
    ])
    error_message = "Azure must return the replacement principals at the original assignment GUIDs with unchanged roles."
  }
}

run "replace_role_definitions" {
  command = apply

  variables {
    name      = run.setup.email_service_name
    location  = run.setup.location
    parent_id = run.setup.parent_id
    role_assignments = {
      for key, assignment in run.setup.role_assignments : key => merge(assignment, {
        principal_id               = run.setup.principal_ids[key == "generated" ? "second" : "first"]
        role_definition_id_or_name = run.setup.replacement_role_ids[key]
      })
    }
  }
}

run "read_replaced_roles" {
  command = apply

  module {
    source = "./tests/integration/fixtures/readback"
  }

  variables {
    parent_id     = run.replace_role_definitions.resource_id
    explicit_name = run.setup.role_assignments.explicit.name
  }

  assert {
    condition = alltrue([
      for key, assignment in output.assignments :
      assignment.name == run.read_initial_assignments.assignments[key].name &&
      lower(assignment.principal_id) == lower(run.setup.principal_ids[key == "generated" ? "second" : "first"]) &&
      lower(assignment.role_definition_id) == lower(run.setup.replacement_role_ids[key])
    ])
    error_message = "Azure must return the replacement role definitions at the original GUIDs with unchanged principals."
  }
}

run "update_descriptions" {
  command = apply

  variables {
    name      = run.setup.email_service_name
    location  = run.setup.location
    parent_id = run.setup.parent_id
    role_assignments = {
      for key, assignment in run.setup.role_assignments : key => merge(assignment, {
        principal_id               = run.setup.principal_ids[key == "generated" ? "second" : "first"]
        role_definition_id_or_name = run.setup.replacement_role_ids[key]
        description                = "Updated by the same-GUID integration test."
      })
    }
  }
}

run "read_updated_descriptions" {
  command = apply

  module {
    source = "./tests/integration/fixtures/readback"
  }

  variables {
    parent_id     = run.update_descriptions.resource_id
    explicit_name = run.setup.role_assignments.explicit.name
  }

  assert {
    condition = alltrue([
      for key, assignment in output.assignments :
      assignment.name == run.read_initial_assignments.assignments[key].name &&
      lower(assignment.principal_id) == lower(run.setup.principal_ids[key == "generated" ? "second" : "first"]) &&
      lower(assignment.role_definition_id) == lower(run.setup.replacement_role_ids[key]) &&
      assignment.description == "Updated by the same-GUID integration test."
    ])
    error_message = "Azure must persist the descriptions without changing assignment GUIDs, principals, or roles."
  }
}

# This covers the name-pinning contract used after import, not the import operation itself.
run "pin_existing_generated_name" {
  command = plan

  variables {
    name      = run.setup.email_service_name
    location  = run.setup.location
    parent_id = run.setup.parent_id
    role_assignments = {
      for key, assignment in run.setup.role_assignments : key => merge(assignment, {
        name                       = run.read_initial_assignments.assignments[key].name
        principal_id               = run.setup.principal_ids[key == "generated" ? "second" : "first"]
        role_definition_id_or_name = run.setup.replacement_role_ids[key]
        description                = "Updated by the same-GUID integration test."
      })
    }
  }

  assert {
    condition = alltrue([
      for key, assignment in azapi_resource.role_assignment :
      lower(assignment.id) == lower(run.read_initial_assignments.assignments[key].id)
    ])
    error_message = "Supplying the existing generated GUID as name must retain the known assignment IDs, not plan replacement."
  }
}
