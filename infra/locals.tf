locals {
  name        = format("stay_updated_%s", var.environment.key)
  environment = var.environment.name
}
