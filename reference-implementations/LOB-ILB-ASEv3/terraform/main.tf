provider "azurerm" {
  features {}
}

locals {
  // Variables
  resourceSuffix              = "${var.workloadName}-${var.environment}-${var.location}-001"
  networkingResourceGroupName = "rgtf-networking-${local.resourceSuffix}"
  sharedResourceGroupName     = "rgtf-shared-${local.resourceSuffix}"
  aseResourceGroupName        = "rgtf-ase-${local.resourceSuffix}"
}

resource "azurerm_resource_group" "networkrg" {
  name     = local.networkingResourceGroupName
  location = var.location
}

resource "azurerm_resource_group" "sharedrg" {
  name     = local.sharedResourceGroupName
  location = var.location
}

resource "azurerm_resource_group" "aserg" {
  name     = local.aseResourceGroupName
  location = var.location
}
