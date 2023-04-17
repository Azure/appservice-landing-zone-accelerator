resource "azurecaf_name" "resource_group" {
  name          = "hub-${var.application_name}"
  resource_type = "azurerm_resource_group"
  suffixes      = [var.location_short]
}

resource "azurerm_resource_group" "hub" {
  name     = azurecaf_name.resource_group.result
  location = var.location

  tags = {
    "terraform" = "true"
  }
}

resource "azurecaf_name" "law" {
  name          = "hub-${var.application_name}"
  resource_type = "azurerm_log_analytics_workspace"
  suffixes      = [var.location_short]
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = azurecaf_name.law.result
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "PerGB2018"
  # internet_ingestion_enabled = false
}

resource "azurecaf_name" "vnet" {
  name          = "hub-${var.application_name}"
  resource_type = "azurerm_virtual_network"
  suffixes      = [var.location_short]
}

locals {
  hub_vnet_cidr        = var.hub_vnet_cidr == null ? ["10.242.0.0/20"] : var.hub_vnet_cidr
  firewall_subnet_cidr = var.firewall_subnet_cidr == null ? ["10.242.0.0/26"] : var.firewall_subnet_cidr
  bastion_subnet_cidr  = var.bastion_subnet_cidr == null ? ["10.242.0.64/26"] : var.bastion_subnet_cidr

  spoke_vnet_cidr    = var.spoke_vnet_cidr == null ? ["10.240.0.0/20"] : var.spoke_vnet_cidr
  devops_subnet_cidr = var.devops_subnet_cidr == null ? ["10.240.10.128/26"] : var.devops_subnet_cidr

  bastion_subnet_name  = "AzureBastionSubnet"
  firewall_subnet_name = "AzureFirewallSubnet"
}

module "network" {
  source = "../../modules/network"

  name           = azurecaf_name.vnet.result
  resource_group = azurerm_resource_group.hub.name
  location       = azurerm_resource_group.hub.location
  vnet_cidr      = local.hub_vnet_cidr

  subnets = [
    {
      name        = local.firewall_subnet_name
      subnet_cidr = local.firewall_subnet_cidr
      delegation  = null
    },
    {
      name        = local.bastion_subnet_name
      subnet_cidr = local.bastion_subnet_cidr
      delegation  = null
  }]
}

resource "azurecaf_name" "bastion_host" {
  name          = "hub-${var.application_name}"
  resource_type = "azurerm_bastion_host"
  suffixes      = [var.location_short]
}

module "bastion" {
  count = var.deployment_options.deploy_bastion ? 1 : 0

  source = "../../modules/bastion"

  name = azurecaf_name.bastion_host.result

  # Retrieve the subnet id by a lookup on subnet name from the list of subnets in the module output
  subnet_id      = module.network.subnets[index(module.network.subnets.*.name, local.bastion_subnet_name)].id
  resource_group = azurerm_resource_group.hub.name
  location       = azurerm_resource_group.hub.location
}

resource "azurecaf_name" "firewall" {
  name          = "hub-${var.application_name}"
  resource_type = "azurerm_firewall"
  suffixes      = [var.location_short]
}

module "firewall" {
  count = var.deployment_options.enable_egress_lockdown ? 1 : 0

  source = "../../modules/firewall"

  name = azurecaf_name.firewall.result

  # Retrieve the subnet id by a lookup on subnet name from the list of subnets in the module output
  subnet_id                  = module.network.subnets[index(module.network.subnets.*.name, local.firewall_subnet_name)].id
  resource_group             = azurerm_resource_group.hub.name
  location                   = azurerm_resource_group.hub.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  firewall_rules_source_addresses = [
    local.hub_vnet_cidr[0],
    local.spoke_vnet_cidr[0]
  ]

  devops_subnet_cidr = local.devops_subnet_cidr
}
