locals {
  display_name = var.display_name == "" ? var.username : var.display_name
}
