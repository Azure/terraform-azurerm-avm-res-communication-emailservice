locals {
  assignments = {
    for assignment in data.azapi_resource_list.assignments.output.assignments : assignment.name => {
      id                 = assignment.id
      name               = assignment.name
      principal_id       = assignment.properties.principalId
      role_definition_id = assignment.properties.roleDefinitionId
      description        = lookup(assignment.properties, "description", null)
    } if lower(assignment.properties.scope) == lower(var.parent_id)
  }
}
