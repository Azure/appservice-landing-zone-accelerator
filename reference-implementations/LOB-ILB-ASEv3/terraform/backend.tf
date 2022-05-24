terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "backend-appsrvc-dev-westus2-001"
    storage_account_name = "stbackendappsrwestus2001"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}