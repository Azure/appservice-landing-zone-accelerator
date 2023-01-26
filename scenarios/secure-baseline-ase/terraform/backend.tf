terraform {
  required_version = ">=1.2" # must be greater than or equal to 1.2 for OIDC

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.7.0"
    }
  }
  backend "azurerm" {}
  # resource_group_name  = "backend-appsrvc-dev-westus2-001"
  # storage_account_name = "stbackendappsrwestus2001"
  # container_name       = "tfstate"
  # key                  = "terraform.tfstate"
}

provider "azurerm" {
  features {}
  disable_terraform_partner_id = false
  partner_id                   = "cf7e9f0a-f872-49db-b72f-f2e318189a6d"
}