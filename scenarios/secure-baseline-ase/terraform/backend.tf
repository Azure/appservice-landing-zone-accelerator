terraform {
  required_version = ">=1.2" # must be greater than or equal to 1.2 for OIDC

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.7.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}

  # DO NOT CHANGE THE BELOW VALUES
  disable_terraform_partner_id = false
  partner_id                   = "cf7e9f0a-f872-49db-b72f-f2e318189a6d"
}