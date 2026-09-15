data "azapi_resource_list" "assignments" {
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  parent_id = var.parent_id
  response_export_values = {
    assignments = "value"
  }
}
