terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.34.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

provider "azurerm" {
  features {}
  disable_terraform_partner_id = false
  partner_id                   = "cf7e9f0a-f872-49db-b72f-f2e318189a6d"
}

locals {
  hub_vnet_cidr            = var.hub_vnet_cidr == null ? ["10.242.0.0/20"] : var.hub_vnet_cidr
  firewall_subnet_cidr     = var.firewall_subnet_cidr == null ? "10.242.0.0/26" : var.firewall_subnet_cidr
  bastion_subnet_cidr      = var.bastion_subnet_cidr == null ? "10.242.0.64/26" : var.bastion_subnet_cidr
  spoke_vnet_cidr          = var.spoke_vnet_cidr == null ? ["10.240.0.0/20"] : var.spoke_vnet_cidr
  appsvc_int_subnet_cidr   = var.appsvc_int_subnet_cidr == null ? ["10.240.0.0/26"] : var.appsvc_int_subnet_cidr
  front_door_subnet_cidr   = var.front_door_subnet_cidr == null ? ["10.240.0.64/26"] : var.front_door_subnet_cidr
  devops_subnet_cidr       = var.devops_subnet_cidr == null ? ["10.240.10.128/26"] : var.devops_subnet_cidr
  private_link_subnet_cidr = var.private_link_subnet_cidr == null ? ["10.240.11.0/24"] : var.private_link_subnet_cidr
  deploy_firewall          = var.enable_egress_lockdown == null ? false : var.enable_egress_lockdown
}

module "hub" {
  source = "./modules/hub"

  location             = var.location
  vnet_cidr            = local.hub_vnet_cidr
  firewall_subnet_cidr = local.firewall_subnet_cidr
  bastion_subnet_cidr  = local.bastion_subnet_cidr
  deploy_firewall      = local.deploy_firewall
  devops_subnet_cidr   = local.devops_subnet_cidr

  firewall_rules_source_addresses = [
    local.hub_vnet_cidr[0],
    local.spoke_vnet_cidr[0]
  ]
}

module "spoke" {
  source = "./modules/spoke"

  application_name          = var.application_name
  environment               = var.environment
  location                  = var.location
  tenant_id                 = var.tenant_id
  aad_admin_group_object_id = var.aad_admin_group_object_id
  aad_admin_group_name      = var.aad_admin_group_name
  vm_admin_username         = var.vm_admin_username
  vm_admin_password         = var.vm_admin_password
  vm_aad_admin_username     = var.vm_aad_admin_username
  vnet_cidr                 = local.spoke_vnet_cidr
  firewall_private_ip       = module.hub.firewall_private_ip
  firewall_rules            = module.hub.firewall_rules
  appsvc_int_subnet_cidr    = local.appsvc_int_subnet_cidr
  front_door_subnet_cidr    = local.front_door_subnet_cidr
  devops_subnet_cidr        = local.devops_subnet_cidr
  private_link_subnet_cidr  = local.private_link_subnet_cidr
  enable_waf                = var.enable_waf
  enable_egress_lockdown    = var.enable_egress_lockdown
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

