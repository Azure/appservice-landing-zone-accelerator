terraform {
  required_version = ">=1.2" # must be greater than or equal to 1.2 for OIDC

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
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  disable_terraform_partner_id = var.partner_id == null ? true : false
  partner_id                   = var.partner_id
}