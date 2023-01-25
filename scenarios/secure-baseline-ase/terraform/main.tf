terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.9.0"
    }

  }
}

provider "azurerm" {
  features {}
  disable_terraform_partner_id = false
  partner_id                   = "cf7e9f0a-f872-49db-b72f-f2e318189a6d"
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
