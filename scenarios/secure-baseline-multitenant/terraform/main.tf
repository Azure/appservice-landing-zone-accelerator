# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = ">=3.39.1"
#     }
#     azurecaf = {
#       source  = "aztfmod/azurecaf"
#       version = ">=1.2.23"
#     }
#   }
# }

# # provider "azurerm" {
# #   features {}
# #   disable_terraform_partner_id = false
# #   partner_id                   = "cf7e9f0a-f872-49db-b72f-f2e318189a6d"
# # }

locals {
  hub_vnet_cidr            = var.hub_vnet_cidr == null ? ["10.242.0.0/20"] : var.hub_vnet_cidr
  firewall_subnet_cidr     = var.firewall_subnet_cidr == null ? "10.242.0.0/26" : var.firewall_subnet_cidr
  bastion_subnet_cidr      = var.bastion_subnet_cidr == null ? "10.242.0.64/26" : var.bastion_subnet_cidr
  spoke_vnet_cidr          = var.spoke_vnet_cidr == null ? ["10.240.0.0/20"] : var.spoke_vnet_cidr
  appsvc_subnet_cidr       = var.appsvc_subnet_cidr == null ? ["10.240.0.0/26"] : var.appsvc_subnet_cidr
  front_door_subnet_cidr   = var.front_door_subnet_cidr == null ? ["10.240.0.64/26"] : var.front_door_subnet_cidr
  devops_subnet_cidr       = var.devops_subnet_cidr == null ? ["10.240.10.128/26"] : var.devops_subnet_cidr
  private_link_subnet_cidr = var.private_link_subnet_cidr == null ? ["10.240.11.0/24"] : var.private_link_subnet_cidr
}

module "hub" {
  source = "./modules/hub"

  location             = var.location
  vnet_cidr            = local.hub_vnet_cidr
  firewall_subnet_cidr = local.firewall_subnet_cidr
  bastion_subnet_cidr  = local.bastion_subnet_cidr
  devops_subnet_cidr   = local.devops_subnet_cidr

  deploy_firewall = var.deployment_options.enable_egress_lockdown
  deploy_bastion  = var.deployment_options.deploy_bastion

  firewall_rules_source_addresses = [
    local.hub_vnet_cidr[0],
    local.spoke_vnet_cidr[0]
  ]
}

module "spoke" {
  source = "./modules/spoke"

  application_name   = var.application_name
  environment        = var.environment
  location           = var.location
  tenant_id          = var.tenant_id
  deployment_options = var.deployment_options
  appsvc_options     = var.appsvc_options

  aad_admin_group_object_id = var.aad_admin_group_object_id
  aad_admin_group_name      = var.aad_admin_group_name
  vm_admin_username         = var.vm_admin_username
  vm_admin_password         = var.vm_admin_password
  vm_aad_admin_username     = var.vm_aad_admin_username

  vnet_cidr                = local.spoke_vnet_cidr
  appsvc_subnet_cidr       = local.appsvc_subnet_cidr
  front_door_subnet_cidr   = local.front_door_subnet_cidr
  devops_subnet_cidr       = local.devops_subnet_cidr
  private_link_subnet_cidr = local.private_link_subnet_cidr
  firewall_private_ip      = module.hub.firewall_private_ip

  private_dns_zones    = module.private_dns_zones.dns_zones
  private_dns_zones_rg = module.hub.rg_name

  providers = {
    azurecaf = azurecaf
  }

  depends_on = [
    module.hub.firewall_rules
  ]
}

module "private_dns_zones" {
  source = "./modules/shared/private-dns-zone"

  resource_group = module.hub.rg_name

  dns_zones = [
    "privatelink.azurewebsites.net",
    "privatelink.database.windows.net",
    "privatelink.azconfig.io",
    "privatelink.vaultcore.azure.net",
    "privatelink.redis.cache.windows.net"
  ]

  vnet_links = [
    {
      vnet_id             = module.hub.vnet_id
      vnet_resource_group = module.hub.rg_name
    },
    {
      vnet_id             = module.spoke.vnet_id
      vnet_resource_group = module.spoke.rg_name
    }
  ]
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "hub-to-spoke-${var.application_name}"
  resource_group_name          = module.hub.rg_name
  virtual_network_name         = module.hub.vnet_name
  remote_virtual_network_id    = module.spoke.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "spoke-to-hub-${var.application_name}"
  resource_group_name          = module.spoke.rg_name
  virtual_network_name         = module.spoke.vnet_name
  remote_virtual_network_id    = module.hub.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
