terraform {
  required_version = ">=1.3" # must be greater than or equal to 1.2 for OIDC

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.66.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.23"
    }
  }
  backend "azurerm" {
    resource_group_name  = "backend-appsrvc-dev-westus2-001"
    storage_account_name = "stbackendappsrwestus2001"
    container_name       = "tfstate"
    key                  = "scenario1.spoke.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = true
    }
  }

  # DO NOT CHANGE THE BELOW VALUES
  disable_terraform_partner_id = false
  partner_id                   = "cf7e9f0a-f872-49db-b72f-f2e318189a6d"
}

provider "azurecaf" {}

resource "azurecaf_name" "caf_name_spoke_rg" {
  name          = var.application_name
  resource_type = "azurerm_resource_group"
  prefixes      = concat(["spoke"], local.global_settings.prefixes)
  random_length = local.global_settings.random_length
  clean_input   = true
  passthrough   = local.global_settings.passthrough
  use_slug      = local.global_settings.use_slug
}

resource "azurerm_resource_group" "spoke" {
  name     = azurecaf_name.caf_name_spoke_rg.result
  location = var.location

  tags = local.base_tags
}