variable "domain_management" {
  type        = string
  description = "(Required) Describes how the Email Communication Service Domain resource is being managed. Possible values are `AzureManaged`, `CustomerManaged` and `CustomerManagedInExchangeOnline`. Changing this forces a new resource to be created."
  nullable    = false

  validation {
    condition     = contains(["AzureManaged", "CustomerManaged", "CustomerManagedInExchangeOnline"], var.domain_management)
    error_message = "`domain_management` must be one of `AzureManaged`, `CustomerManaged` or `CustomerManagedInExchangeOnline`."
  }
}

variable "name" {
  type        = string
  description = "(Required) The name of the Email Communication Service Domain resource. If `domain_management` is `AzureManaged`, the name must be `AzureManagedDomain`. Changing this forces a new resource to be created."
  nullable    = false
}

variable "parent_id" {
  type        = string
  description = "(Required) The fully-qualified ARM resource ID of the existing Email Communication Service that will contain the domain."
  nullable    = false

  validation {
    condition     = can(provider::azapi::parse_resource_id("Microsoft.Communication/emailServices", var.parent_id))
    error_message = "`parent_id` must be a valid `Microsoft.Communication/emailServices` resource ID."
  }
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
    communication_email_services_domains = optional(list(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Paths in the resource's `body` whose changes the AzAPI provider ignores. Prefer Terraform's `lifecycle.ignore_changes` when the paths are static; use this variable when the paths must be derived from variables or other non-static values.

Paths use dot notation, for example `properties.userEngagementTracking`. Individual list items cannot be targeted, so ignore the whole list property instead. Configuration changes at an ignored path are **not** sent to Azure until that path is removed from the list.

Supplying a non-empty value requires Terraform 1.11 or later, because `ignore_body_changes` is a write-only argument. Changes take effect only after an apply, because the value is held in provider-private state.

- `communication_email_services_domains` - Ignored body paths for the Email Communication Service Domain managed by this module.
DESCRIPTION
  nullable    = false
}

variable "resource_types" {
  type = object({
    communication_email_services_domains = optional(string, "Microsoft.Communication/emailServices/domains@2023-03-31")
  })
  default     = {}
  description = <<DESCRIPTION
Override the AzAPI `<provider>/<resource>@<api-version>` strings used by this module. Each key defaults to a tested value; supply only the keys you want to override. Useful when targeting a sovereign cloud with older API versions, or when opting into a newer preview API.

- `communication_email_services_domains` - The Email Communication Service Domain managed by this module.
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

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags which should be assigned to the Email Communication Service Domain."
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

variable "user_engagement_tracking_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Describes whether user engagement tracking is enabled. Defaults to `false`."
  nullable    = false
}
