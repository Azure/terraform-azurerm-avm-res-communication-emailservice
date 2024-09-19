variable "domain_id" {
  type        = string
  description = "The ID of the Email Communication Service Domain where the sender username should be created."
  nullable    = false

  validation {
    error_message = "Value must be a valid Azure Email Communication Service resource ID."
    condition     = can(regex("\\/subscriptions\\/[a-f\\d]{4}(?:[a-f\\d]{4}-){4}[a-f\\d]{12}\\/(?i:resourceGroups\\/[^\\/]+\\/providers\\/Microsoft.Communication\\/EmailServices)\\/(?i:[^\\/]+\\/Domains\\/[^\\/]+)$", var.domain_id))
  }
}

variable "name" {
  type        = string
  description = "The name of the sender username resource."
  nullable    = false
}


variable "username" {
  type        = string
  description = "The sender username to be used when sending emails."
  nullable    = false
}

variable "display_name" {
  type        = string
  description = "The display name for the sender Username. If not provided, the username will be used."
  nullable    = false
  default     = ""
}
