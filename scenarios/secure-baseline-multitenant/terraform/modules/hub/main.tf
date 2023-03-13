terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.23"
    }
  }
}

resource "azurecaf_name" "resource_group" {
  name          = "hub"
  resource_type = "azurerm_resource_group"
  suffixes      = [var.location]
}

resource "azurerm_resource_group" "hub" {
  name     = azurecaf_name.resource_group.result
  location = var.location

  tags = {
    "terraform" = "true"
  }
}

resource "azurecaf_name" "law" {
  name          = "hub"
  resource_type = "azurerm_log_analytics_workspace"
  suffixes      = [var.location]
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = azurecaf_name.law.result
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "PerGB2018"
  # internet_ingestion_enabled = false
}

resource "azurecaf_name" "vnet" {
  name          = "hub"
  resource_type = "azurerm_virtual_network"
  suffixes      = [var.location]
}

locals {
  bastion_subnet_name  = "AzureBastionSubnet"
  firewall_subnet_name = "AzureFirewallSubnet"
}

module "network" {
  source = "../shared/network"

  name           = azurecaf_name.vnet.result
  resource_group = azurerm_resource_group.hub.name
  location       = azurerm_resource_group.hub.location
  vnet_cidr      = var.vnet_cidr

  subnets = [
    {
      name        = local.firewall_subnet_name
      subnet_cidr = [var.firewall_subnet_cidr]
      delegation  = null
    },
    {
      name        = local.bastion_subnet_name
      subnet_cidr = [var.bastion_subnet_cidr]
      delegation  = null
  }]
}

module "bastion" {
  count = var.deploy_bastion ? 1 : 0

  source = "./bastion"

  # Retrieve the subnet id by a lookup on subnet name from the list of subnets in the module output
  subnet_id      = module.network.subnets[index(module.network.subnets.*.name, local.bastion_subnet_name)].id
  resource_group = azurerm_resource_group.hub.name
  location       = azurerm_resource_group.hub.location
}

module "firewall" {
  count = var.deploy_firewall ? 1 : 0

  source = "./firewall"

  # Retrieve the subnet id by a lookup on subnet name from the list of subnets in the module output
  subnet_id                       = module.network.subnets[index(module.network.subnets.*.name, local.firewall_subnet_name)].id
  resource_group                  = azurerm_resource_group.hub.name
  location                        = azurerm_resource_group.hub.location
  log_analytics_workspace_id      = azurerm_log_analytics_workspace.law.id
  firewall_rules_source_addresses = var.firewall_rules_source_addresses
  devops_subnet_cidr              = var.devops_subnet_cidr
}
