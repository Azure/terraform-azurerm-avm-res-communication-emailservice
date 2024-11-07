<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-res-communication-emailservice//domain

Module to deploy email communication service domain in Azure.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.109)

## Resources

The following resources are used by this module:

- [azurerm_email_communication_service_domain.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/email_communication_service_domain) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_email_service_id"></a> [email\_service\_id](#input\_email\_service\_id)

Description: The ID of the Email Communication Service where the domain should be created.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the domain.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_domain_management"></a> [domain\_management](#input\_domain\_management)

Description: (Optional) Describes how the domain resource is being managed.

Type: `string`

Default: `"AzureManaged"`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:

```hcl
object({
    kind = string
    name = optional(string, null)
  })
```

Default: `null`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description:   A map of role assignments to create on the Email Communication Service Domain. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_sender_usernames"></a> [sender\_usernames](#input\_sender\_usernames)

Description: A map of sender usernames to create on the Email Communication Service Domain. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - The name of the domain.
- `username` - The sender username to be used when sending emails.
- `display_name` - (Optional) The display name for the sender Username.

Type:

```hcl
map(object({
    name         = string
    username     = string
    display_name = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the Email Communication Service Domain.

Type: `map(string)`

Default: `null`

### <a name="input_user_engagement_tracking_enabled"></a> [user\_engagement\_tracking\_enabled](#input\_user\_engagement\_tracking\_enabled)

Description: (Optional) Describes whether user engagement tracking is enabled or disabled.

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### <a name="output_from_sender_domain"></a> [from\_sender\_domain](#output\_from\_sender\_domain)

Description: P2 sender domain that is displayed to the email recipients [RFC 5322].

### <a name="output_mail_from_sender_domain"></a> [mail\_from\_sender\_domain](#output\_mail\_from\_sender\_domain)

Description: P1 sender domain that is present on the email envelope [RFC 5321].

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the domain

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The Azure resource id of the domain.

### <a name="output_verification_records"></a> [verification\_records](#output\_verification\_records)

Description: Verification records for the domain.

## Modules

The following Modules are called:

### <a name="module_sender_usernames"></a> [sender\_usernames](#module\_sender\_usernames)

Source: ./modules/sender_username

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->