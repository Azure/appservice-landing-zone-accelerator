locals {
  deployment_name = "sec-baseline-1-hub"

  global_settings = merge({
    environment = try(var.global_settings.environment, var.environment)
    passthrough = try(var.global_settings.passthrough, false)
    prefixes    = try(var.global_settings.prefixes, [local.deployment_name, local.short_location])
    suffixes    = try(var.global_settings.suffixes, [var.environment])
    # prefixes    = try(var.global_settings.prefixes, [var.application_name, local.short_location])

    random_length = try(var.global_settings.random_length, 0)
    regions       = try(var.global_settings.regions, null)
    tags          = try(var.global_settings.tags, null)
    use_slug      = try(var.global_settings.use_slug, true)
  }, var.global_settings)

  short_location_map = {
    "eastus" : "eus"
    "eastus2" : "eus2"
    "westus" : "wus"
    "westus2" : "wus2"
    "westeurope" : "weu"
    "easteurope" : "eeu"
    "southcentralus" : "scus"
  }

  short_location = try(local.short_location_map[var.location], var.location)

  base_tags = merge({
    "Terraform"   = true
    "Environment" = local.global_settings.environment
    "Owner"       = var.owner
    "Project"     = "[Scenario 1: HUB] App Service Landing Zone Accelerator"
  }, var.tags)
}

