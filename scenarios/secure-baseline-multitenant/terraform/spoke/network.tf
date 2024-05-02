# Spoke network config
# -----
# - Spoke Resource Group
#   - VNet
#      - Server Farm Subnet (App Service/compute resources)
#      - Ingress Subnet (Azure Front Door network ingress subnet)
#      - Private Link Subnet (Private DNS Zones)
#      - DevOps Subnet (optional Self Hosted CICD agent)
#   - Private DNS Zones
#   - User Defined Routes [optional]
#   - Azure FrontDoor

## Create Spoke Resource Group with the name generated from global_settings
resource "azurecaf_name" "caf_name_spoke_rg" {
  name          = var.application_name
  resource_type = "azurerm_resource_group"
  prefixes      = concat(["spoke"], local.global_settings.prefixes)
  random_length = local.global_settings.random_length
  clean_input   = true
  passthrough   = local.global_settings.passthrough
  use_slug      = local.global_settings.use_slug
}

resource "azurerm_resource_group" "spoke" {
  name     = azurecaf_name.caf_name_spoke_rg.result
  location = var.location

  tags = local.base_tags
}

resource "azurecaf_name" "appsvc_subnet" {
  name          = var.application_name
  resource_type = "azurerm_subnet"
  prefixes      = concat(["spoke"], local.global_settings.prefixes)
  random_length = local.global_settings.random_length
  clean_input   = true
  passthrough   = local.global_settings.passthrough
  use_slug      = local.global_settings.use_slug
}

## Deploy Spoke VNet with Server Farm, Ingress, Private Link and DevOps subnets
module "network" {
  source = "../../../shared/terraform-modules/network"

  global_settings = local.global_settings
  resource_group  = azurerm_resource_group.spoke.name
  location        = var.location
  name            = var.application_name
  vnet_cidr       = var.spoke_vnet_cidr
  peering_vnet = {
    id             = var.hub_virtual_network.id
    name           = var.hub_virtual_network.name
    resource_group = var.hub_virtual_network.resource_group_name
  }

  subnets = [
    {
      name        = "serverFarm"
      subnet_cidr = var.appsvc_subnet_cidr
      delegation = {
        name = "Microsoft.Web/serverFarms"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    },
    {
      name        = "ingress"
      subnet_cidr = var.front_door_subnet_cidr
      delegation  = null
    },
    {
      name        = "devops"
      subnet_cidr = var.devops_subnet_cidr
      delegation  = null
    },
    {
      name        = "privateLink"
      subnet_cidr = var.private_link_subnet_cidr
      delegation  = null
    }
  ]

  tags = local.base_tags
}

## Deploy Private DNS Zones
module "private_dns_zones" {
  source = "../../../shared/terraform-modules/private-dns-zone"
  count  = length(local.private_dns_zones)

  resource_group  = var.hub_virtual_network.resource_group_name
  global_settings = local.global_settings

  dns_zone_name = local.private_dns_zones[count.index].name
  dns_records   = lookup(local.private_dns_zones[count.index], "records", [])
  vnet_links = [
    var.hub_virtual_network.id
  ]

  tags = local.base_tags
}

# TODO: Deprecate the random_integer unique_id logic
resource "random_integer" "unique_id" {
  min = 1
  max = 9999
}

## Deploy Azure Front Door with basic endpoint configuration for the web app
module "frontdoor" {
  source = "../../../shared/terraform-modules/frontdoor"

  resource_group             = azurerm_resource_group.spoke.name
  application_name           = var.application_name
  environment                = var.environment
  location                   = var.location
  enable_waf                 = var.deployment_options.enable_waf
  unique_id                  = random_integer.unique_id.result
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  enable_diagnostic_settings = var.deployment_options.enable_diagnostic_settings
  global_settings            = local.global_settings

  endpoint_settings = [
    {
      endpoint_name            = "${var.application_name}-${var.environment}"
      web_app_id               = module.app_service.web_app_id
      web_app_hostname         = module.app_service.web_app_hostname
      private_link_target_type = "sites"
    }
  ]

  tags = local.base_tags

  depends_on = [
    module.app_service
  ]
}

## Deploy User Defined Routes (UDR) to route all traffic to the Azure Firewall (enabled via deployment option)
module "user_defined_routes" {
  count = var.deployment_options.enable_egress_lockdown ? 1 : 0

  source = "../../../shared/terraform-modules/user-defined-routes"

  resource_group   = azurerm_resource_group.spoke.name
  location         = var.location
  route_table_name = "egress-lockdown"
  global_settings  = local.global_settings

  routes = [
    {
      name                   = "defaultRoute"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip
    }
  ]

  subnet_ids = module.network.subnet_ids
  tags       = local.base_tags
}
