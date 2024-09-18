variable "email_service_id" {
  type        = string
  description = "The ID of the Email Communication Service where the domain should be created."
  nullable    = false

  validation {
    error_message = "Value must be a valid Azure Email Communication Service resource ID."
    condition     = can(regex("\\/subscriptions\\/[a-f\\d]{4}(?:[a-f\\d]{4}-){4}[a-f\\d]{12}\\/(?i:resourceGroups\\/[^\\/]+\\/providers\\/Microsoft.Communication\\/EmailServices)\\/[^\\/]+$", var.email_service_id))
  }
}

variable "name" {
  type        = string
  description = "The name of the domain."
  nullable    = false

  validation {
    error_message = "The domain name must be either 'AzureManagedDomain' or a valid domain name, which can include letters, numbers, hyphens (-), and underscores (_), with a maximum length of 63 characters. The labels must be separated by dots (.)."
    condition     = can(regex("^(AzureManagedDomain|([a-zA-Z0-9-_]{1,63}\\.)+[a-zA-Z]{2,6})$", var.name))
  }
}

variable "domain_management" {
  type        = string
  default     = "AzureManaged"
  description = "(Optional) Describes how the domain resource is being managed."
  nullable    = false

  validation {
    condition     = contains(["AzureManaged", "CustomerManaged", "CustomerManagedInExchangeOnline"], var.domain_management)
    error_message = "Invalid value for domain management. Valid options are 'AzureManaged', 'CustomerManaged', 'CustomerManagedInExchangeOnline'."
  }
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
  A map of role assignments to create on the Email Communication Service Domain. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  
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
  description = "(Optional) Tags of the Email Communication Service Domain."
}

variable "user_engagement_tracking_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Describes whether user engagement tracking is enabled or disabled."
}
