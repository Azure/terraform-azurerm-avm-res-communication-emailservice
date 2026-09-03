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

variable "parent_id" {
  type        = string
  description = "(Required) The fully-qualified ARM resource ID of the existing resource group into which the Email Communication Service will be deployed. Changing this forces a new resource to be created."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Resources/resourceGroups", var.parent_id))
    error_message = "`parent_id` must be a valid resource group resource ID."
  }
}

variable "email_communication_service_domain_sender_usernames" {
  type = map(object({
    name                                        = string
    email_communication_service_domain_name_key = string
    display_name                                = optional(string, "")
  }))
  default     = {}
  description = <<DESCRIPTION
A map of Email Communication Service Domains to create on Email Communcation Service.

- `name` - The name of the Email Communication Service Domain Sender Username resource. Changing this forces a new resource to be created.
- `email_communication_service_domain_name_key` - The key name of the Email Communication Service Domain resource. Changing this forces a new resource to be created.
- `display_name` - The display name for the Email Communication Service Domain Sender Username resource.

DESCRIPTION
  nullable    = false
}

variable "email_communication_service_domains" {
  type = map(object({
    name                             = string
    domain_management                = string
    user_engagement_tracking_enabled = optional(bool, false)
    tags                             = optional(map(string), null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of Email Communication Service Domains to create on Email Communcation Service.

- `name` - The name of the Email Communication Service Domain resource. If `domain_management` is `AzureManaged`, the name must be `AzureManagedDomain`. Changing this forces a new resource to be created.
- `domain_management` - Describes how a Email Communication Service Domain resource is being managed. Possible values are `AzureManaged`, `CustomerManaged`, `CustomerManagedInExchangeOnline`. Changing this forces a new resource to be created.
- `user_engagement_tracking_enabled` - Describes user engagement tracking is enabled or disabled. Defaults to `false`.
- `tags` - A mapping of tags which should be assigned to the Email Communication Service Domain.

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

variable "ignore_body_changes" {
  type = object({
    communication_email_services   = optional(list(string), [])
    authorization_locks            = optional(list(string), [])
    authorization_role_assignments = optional(list(string), [])
    communication_email_services_domains = optional(object({
      communication_email_services_domains = optional(list(string), [])
    }), {})
    communication_email_services_domains_sender_usernames = optional(object({
      communication_email_services_domains_sender_usernames = optional(list(string), [])
    }), {})
  })
  default     = {}
  description = <<DESCRIPTION
Lists of JSON paths in the request body that this module should stop managing after creation, keyed by resource. Use this when another process mutates part of a resource and you want Terraform to leave those properties alone.

- `communication_email_services` - Paths to ignore on the Email Communication Service.
- `authorization_locks` - Paths to ignore on the management lock.
- `authorization_role_assignments` - Paths to ignore on the role assignments.
- `communication_email_services_domains.communication_email_services_domains` - Paths to ignore on each Email Communication Service Domain.
- `communication_email_services_domains_sender_usernames.communication_email_services_domains_sender_usernames` - Paths to ignore on each Email Communication Service Domain Sender Username.

Example: `["properties.userEngagementTracking"]`
DESCRIPTION
  nullable    = false
}

variable "lock" {
  type = object({
    kind  = string
    name  = optional(string, null)
    notes = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
- `notes` - (Optional) Notes about the lock. Maximum of 512 characters.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "resource_types" {
  type = object({
    communication_email_services   = optional(string, "Microsoft.Communication/emailServices@2023-03-31")
    authorization_locks            = optional(string, "Microsoft.Authorization/locks@2020-05-01")
    authorization_role_assignments = optional(string, "Microsoft.Authorization/roleAssignments@2022-04-01")
    communication_email_services_domains = optional(object({
      communication_email_services_domains = optional(string)
    }), {})
    communication_email_services_domains_sender_usernames = optional(object({
      communication_email_services_domains_sender_usernames = optional(string)
    }), {})
  })
  default     = {}
  description = <<DESCRIPTION
The ARM resource type and API version used for each resource this module deploys. Override an entry to pin a different API version.

- `communication_email_services` - The Email Communication Service.
- `authorization_locks` - The management lock.
- `authorization_role_assignments` - The role assignments.
- `communication_email_services_domains.communication_email_services_domains` - Each Email Communication Service Domain.
- `communication_email_services_domains_sender_usernames.communication_email_services_domains_sender_usernames` - Each Email Communication Service Domain Sender Username.
DESCRIPTION
  nullable    = false
}

variable "retry" {
  type = object({
    error_message_regex  = optional(list(string))
    interval_seconds     = optional(number)
    max_interval_seconds = optional(number)
  })
  default     = null
  description = <<DESCRIPTION
Retry configuration applied to every supported AzAPI resource declared by the module and its applicable submodules. Defaults to `null` (no custom retry).

- `error_message_regex`  - (Optional) A list of regex patterns matching error messages that trigger a retry.
- `interval_seconds`     - (Optional) Initial interval between retries in seconds.
- `max_interval_seconds` - (Optional) Maximum interval between retries in seconds.

See <https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource#retry> for full semantics.
DESCRIPTION
}

variable "role_assignments" {
  type = map(object({
    name                                   = optional(string, null)
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

- `name` - (Optional) The name of the role assignment. If not specified, a GUID will be generated. Changing this forces the creation of a new resource.
- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - Has no effect when the role assignment is created with AzAPI, and is retained for backwards compatibility.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.
- `delegated_managed_identity_resource_id` - The delegated Azure Resource Id which contains a Managed Identity. Changing this forces a new resource to be created.
- `principal_type` - The type of the principal_id. Possible values are `User`, `Group` and `ServicePrincipal`. Changing this forces a new resource to be created. It is necessary to explicitly set this attribute when creating role assignments if the principal creating the assignment is constrained by ABAC rules that filters on the PrincipalType attribute.
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue([
      for _, v in var.role_assignments :
      v.delegated_managed_identity_resource_id == null ? true : can(provider::azapi::parse_resource_id("Microsoft.ManagedIdentity/userAssignedIdentities", v.delegated_managed_identity_resource_id))
    ])
    error_message = "`delegated_managed_identity_resource_id`, when supplied, must be a valid `Microsoft.ManagedIdentity/userAssignedIdentities` resource ID."
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags which should be assigned to the Email Communication Service."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
Default per-operation timeouts applied to every supported AzAPI resource declared by the module and its applicable submodules. Defaults to `null` (provider defaults). Each value is a Go duration string (e.g. `30m`, `1h`).

- `create` - (Optional) Timeout for create operations.
- `read`   - (Optional) Timeout for read operations.
- `update` - (Optional) Timeout for update operations.
- `delete` - (Optional) Timeout for delete operations.
DESCRIPTION
}
