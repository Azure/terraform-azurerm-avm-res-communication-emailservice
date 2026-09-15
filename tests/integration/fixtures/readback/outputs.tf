output "assignments" {
  value = {
    explicit  = local.assignments[var.explicit_name]
    generated = one([for name, assignment in local.assignments : assignment if name != var.explicit_name])
  }

  precondition {
    condition     = length(local.assignments) == 2
    error_message = "The isolated email service must have exactly the generated and explicitly named role assignments."
  }
}
