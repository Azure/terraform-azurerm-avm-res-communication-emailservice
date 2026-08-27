# terraform-azurerm-avm-res-communication-emailservice

This is an AVM module to deploy Email Communication Service in Azure.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
> 
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
> 
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

## Upgrading from v0.2.x to v0.3.0

v0.3.0 removes the `hashicorp/azurerm` provider and moves the domain and sender username resources into submodules so that per-domain tags keep working. This changes the addresses of existing resources in state, and Terraform will plan to destroy and recreate them unless you move them first. Run these `terraform state mv` commands once, before the first `terraform plan` against v0.3.0, substituting your own module address and map keys.

```shell
# For every key in var.email_communication_service_domains
terraform state mv \
  'module.<your_module>.azapi_resource.email_communication_service_domain["<key>"]' \
  'module.<your_module>.module.domain["<key>"].azapi_resource.this'

# For every key in var.email_communication_service_domain_sender_usernames
terraform state mv \
  'module.<your_module>.azapi_resource.email_communication_service_domain_sender_username["<key>"]' \
  'module.<your_module>.module.domain_sender_username["<key>"].azapi_resource.this'
```

Locks and role assignments moved from the AzureRM provider to AzAPI, which Terraform cannot migrate with `state mv`. Remove them from state and import them again:

```shell
# Only if you set var.lock
terraform state rm 'module.<your_module>.azurerm_management_lock.this[0]'
terraform import \
  'module.<your_module>.azapi_resource.lock["lock"]' \
  '<email_communication_service_id>/providers/Microsoft.Authorization/locks/<lock_name>?api-version=2020-05-01'

# For every key in var.role_assignments
terraform state rm 'module.<your_module>.azurerm_role_assignment.this["<key>"]'
terraform import \
  'module.<your_module>.azapi_resource.role_assignment["<key>"]' \
  '<existing_role_assignment_id>?api-version=2022-04-01'
```

Role assignment names are GUIDs that Azure generated for you. If you would rather not import, set the new `name` attribute on each entry in `var.role_assignments` to the GUID at the end of the existing role assignment ID, so the module recreates the assignment with the same name instead of failing on a duplicate.

Two other changes are breaking:

- The `resource` output was removed because AVM modules must not export whole resource objects. Use `resource_id`, `name`, or the new `domain_*` outputs instead.
- `skip_service_principal_aad_check` on `var.role_assignments` is accepted but has no effect, because AzAPI does not implement the check.
