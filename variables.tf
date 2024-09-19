variable "data_location" {
  type        = string
  description = "(Required) The location where the communication service stores its data at rest."
}

variable "name" {
  type        = string
  description = "The name of the this Email Communication Service."

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name))
    error_message = "The name must be between 1 and 63 characters long and can only contain letters and numbers and hyphens."
  }
  validation {
    error_message = "The name must not contain two consecutive dashes"
    condition     = !can(regex("--", var.name))
  }
  validation {
    error_message = "The name must start with a letter"
    condition     = can(regex("^[a-zA-Z]", var.name))
  }
  validation {
    error_message = "The name must end with a letter or number"
    condition     = can(regex("[a-zA-Z0-9]$", var.name))
  }
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "domains" {
  type = map(object({
    name                             = string
    domain_management                = optional(string, null)
    user_engagement_tracking_enabled = optional(bool, false)
    tags                             = optional(map(any), null)

    sender_usernames = optional(map(object({
      name         = string
      username     = string
      display_name = optional(string, null)
    })), {})

    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)

    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
  }))
  default     = {}
  description = <<DESCRIPTION
A map of domains to create on the Email Communication Service. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - The name of the domain.
- `domain_management` - (Optional) Describes how the domain resource is being managed.
- `user_engagement_tracking_enabled` - (Optional) Describes whether user engagement tracking is enabled or disabled.
- `lock` - (Optional) The lock level to apply to the domain. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.
- `role_assignments` - (Optional) A map of role assignments to create on the domain. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. See `var.role_assignments` for more information.
- `tags` - (Optional) A mapping of tags to assign to the domain.
DESCRIPTION
  nullable    = false
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
DESCRIPTION
  nullable    = false
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
  A map of role assignments to create on the Email Communication Service. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  
  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - (Optional) The description of the role assignment.
  - `skip_service_principal_aad_check` - (Optional) If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - (Optional) The condition which will be used to scope the role assignment.
  - `condition_version` - (Optional) The version of the condition syntax. Leave as `null` if you are not using a condition, if you are then valid values are '2.0'.
  - `delegated_managed_identity_resource_id` - (Optional) The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created. This field is only used in cross-tenant scenario.
  - `principal_type` - (Optional) The type of the `principal_id`. Possible values are `User`, `Group` and `ServicePrincipal`. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.
  
  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
  DESCRIPTION
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
