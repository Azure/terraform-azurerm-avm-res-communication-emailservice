locals {
  # This submodule deploys a global resource and takes no `location` input, so the
  # telemetry record reports the location the parent Email Communication Service uses.
  main_location = "global"
}
