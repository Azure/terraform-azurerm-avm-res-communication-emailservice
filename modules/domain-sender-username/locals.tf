locals {
  # This submodule deploys a resource that has no location of its own, so the
  # telemetry record cannot report one.
  main_location = "unknown"
}
