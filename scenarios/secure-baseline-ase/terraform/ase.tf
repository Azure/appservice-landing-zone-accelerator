data "azurerm_app_service_environment_v3" "existing" {
  # count               = var.app_service_environment_name != null && var.app_service_environment_resource_group_name != null ? 1 : 0
  count               = local.create_new_ase ? 0 : 1
  name                = var.app_service_environment_name
  resource_group_name = var.app_service_environment_resource_group_name
}

data "azurerm_private_dns_zone" "existing" {
  # count               = var.private_dns_zone_name != null && var.private_dns_zone_resource_group_name != null ? 1 : 0
  count               = local.create_new_private_dns ? 0 : 1
  name                = var.private_dns_zone_name
  resource_group_name = var.private_dns_zone_resource_group_name
}

data "azurerm_virtual_network" "existing_spoke_vnet" {
  # count               = var.spoke_vnet_name != null && var.spoke_vnet_resource_group_name != null ? 1 : 0
  count               = local.create_new_vnet ? 0 : 1
  name                = var.spoke_vnet_name
  resource_group_name = var.spoke_vnet_resource_group_name
}


resource "azurecaf_name" "caf_name_ase_v3" {
  count = local.create_new_ase ? 1 : 0

  name          = var.application_name
  resource_type = "azurerm_app_service_environment"
  prefixes      = local.global_settings.prefixes
  random_length = local.global_settings.random_length
  clean_input   = true
  passthrough   = local.global_settings.passthrough
  use_slug      = local.global_settings.use_slug
}

resource "azurerm_app_service_environment_v3" "ase" {
  count = local.create_new_ase ? 1 : 0

  name                         = azurecaf_name.caf_name_ase_v3[0].result
  resource_group_name          = azurerm_resource_group.ase.name
  subnet_id                    = module.vnetSpoke[0].subnets["hostingEnvironment"].id
  internal_load_balancing_mode = "Web, Publishing"
  zone_redundant               = true
}

module "vnetSpoke" {
  count = local.create_new_vnet ? 1 : 0

  source = "../../shared/terraform-modules/network"

  global_settings = local.global_settings
  resource_group  = azurerm_resource_group.network.name
  location        = azurerm_resource_group.network.location
  name            = var.application_name
  vnet_cidr       = var.spokeVNetNameAddressPrefix

  # peering_vnet = module.vnetHub.vnet

  peering_vnet = {
    id             = module.vnetHub.vnet_id
    name           = module.vnetHub.vnet_name
    resource_group = azurerm_resource_group.network.name
  }

  subnets = [
    {
      name        = "hostingEnvironment"
      subnet_cidr = var.aseAddressPrefix
      delegation = {
        name = "Microsoft.Web/serverFarms"
        service_delegation = {
          name = "Microsoft.Web/hostingEnvironments"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action",
            "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
          ]
        }
      }
    }
  ]

  tags = local.base_tags
}


module "private_dns_zones_ase" {
  count = local.create_new_private_dns ? 1 : 0

  source = "../../shared/terraform-modules/private-dns-zone"

  resource_group  = azurerm_resource_group.ase.name
  global_settings = local.global_settings
  dns_zone_name   = local.privateDnsZoneName

  vnet_links = [
    module.vnetSpoke[0].vnet_id
  ]

  dns_records = [
    {
      dns_name = "*"
      records  = local.ase.internal_inbound_ip_addresses
    },

    {
      dns_name = "*.scm"
      records  = local.ase.internal_inbound_ip_addresses
    },

    {
      dns_name = "@"
      records  = local.ase.internal_inbound_ip_addresses
    }
  ]

  tags = local.base_tags
}
