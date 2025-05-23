variable "data_location" {
  type        = string
  description = "(Required) The location where the Email Communication service stores its data at rest. Possible values are `Africa`, `Asia Pacific`, `Australia`, `Brazil`, `Canada`, `Europe`, `France`, `Germany`, `India`, `Japan`, `Korea`, `Norway`, `Switzerland`, `UAE`, `UK` `usgov` and `United States`. Changing this forces a new resource to be created."
  nullable    = false
}

variable "location" {
  type        = string
  description = "(Required) Azure region where the resource should be deployed. Changing this forces a new resource to be created."
  nullable    = false
}

variable "name" {
  type        = string
  description = "(Required) The name of the Email Communication Service resource. Changing this forces a new resource to be created."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "(Required) The resource group where the resources will be deployed. Changing this forces a new resource to be created."
  nullable    = false
}

variable "email_communication_service_domains" {
  type = map(object({
    email_communication_service_domain_name = string
    domain_management                       = string
    user_engagement_tracking_enabled        = optional(bool, false)
    email_communication_service_domain_tags = optional(map(string), null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of Email Communication Service Domains to create on Email Communcation Service.

- `email_communication_service_domain_name` - The name of the Email Communication Service Domain resource. If `domain_management` is `AzureManaged`, the name must be `AzureManagedDomain`. Changing this forces a new resource to be created.
- `domain_management` - Describes how a Email Communication Service Domain resource is being managed. Possible values are `AzureManaged`, `CustomerManaged`, `CustomerManagedInExchangeOnline`. Changing this forces a new resource to be created.
- `user_engagement_tracking_enabled` - Describes user engagement tracking is enabled or disabled. Defaults to `false`.
- `email_communication_service_domain_tags` - A mapping of tags which should be assigned to the Email Communication Service Domain.

DESCRIPTION
  nullable    = false
}

variable "email_communication_service_domain_sender_usernames" {
  type = map(object({
    email_communication_service_domain_sender_username = string
    email_communication_service_domain_name_key        = string
    display_name                                       = optional(string, "")
  }))
  default     = {}
  description = <<DESCRIPTION
A map of Email Communication Service Domains to create on Email Communcation Service.

- `email_communication_service_domain_sender_username_name` - The name of the Email Communication Service Domain Sender Username resource. Changing this forces a new resource to be created.
- `email_communication_service_domain_name_key` - The key name of the Email Communication Service Domain resource. Changing this forces a new resource to be created.
- `display_name` - The display name for the Email Communication Service Domain Sender Username resource.

DESCRIPTION
  nullable    = false
}

variable "email_communication_service_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags which should be assigned to the Email Communication Service."
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
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.
- `delegated_managed_identity_resource_id` - The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
- `principal_type` - The type of the principal_id. Possible values are `User`, `Group` and `ServicePrincipal`. Changing this forces a new resource to be created. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags which should be assigned to the Resource Group."
}
