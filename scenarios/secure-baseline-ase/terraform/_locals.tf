
locals {
  privateDnsZoneName = "${local.ase.name}.appserviceenvironment.net"

  create_new_ase                    = var.app_service_environment_name == null && var.app_service_environment_resource_group_name == null ? true : false
  create_new_vnet                   = var.spoke_vnet_name == null && var.spoke_vnet_resource_group_name == null ? true : false
  create_new_private_dns            = var.private_dns_zone_name == null && var.private_dns_zone_resource_group_name == null ? true : false
  ase                               = local.create_new_ase ? azurerm_app_service_environment_v3.ase[0] : data.azurerm_app_service_environment_v3.existing[0]
  ase_internal_inbound_ip_addresses = local.create_new_ase ? azurerm_app_service_environment_v3.ase[0].internal_inbound_ip_addresses : data.azurerm_app_service_environment_v3.existing[0].internal_inbound_ip_addresses

  private_dns_zone = var.private_dns_zone_name == null || var.private_dns_zone_resource_group_name == null ? module.private_dns_zones_ase[0].dns_zone : data.azurerm_private_dns_zone.existing[0]
  spokeVNet        = var.spoke_vnet_name == null || var.spoke_vnet_resource_group_name == null ? module.vnetSpoke[0].vnet : data.azurerm_virtual_network.existing_spoke_vnet[0]

  deployment_name = "secure-baseline-2-ase"

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
    "Project"     = "[Scenario 2] App Service Landing Zone Accelerator"
  }, var.tags)
}




