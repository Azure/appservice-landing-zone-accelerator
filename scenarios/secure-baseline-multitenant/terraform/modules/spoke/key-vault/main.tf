terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

data "azurerm_client_config" "current" { }

data "azuread_user" "author" {
  object_id = data.azurerm_client_config.current.object_id
}

resource "azurecaf_name" "key_vault" {
  name          = "appsvc"
  resource_type = "azurerm_key_vault"
  suffixes      = [var.environment, var.unique_id]
}

resource "azurerm_key_vault" "key_vault" {
  name                          = azurecaf_name.key_vault.result
  resource_group_name           = var.resource_group
  location                      = var.location
  enabled_for_disk_encryption   = true
  tenant_id                     = var.tenant_id
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  sku_name                      = var.sku_name
  public_network_access_enabled = false

  network_acls {
    bypass                     = "AzureServices"
    default_action             = "Deny"
  }

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.web_app_principal_id
    key_permissions = [
      "Get",
    ]
    secret_permissions = [
      "Get", "List"
    ]
  }

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.web_app_slot_principal_id
    key_permissions = [
      "Get",
    ]
    secret_permissions = [
      "Get", "List"
    ]
  }

  #Assign access to $User to manage secrets
  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get", "List", "Set"
    ]
  }
}

resource "azurecaf_name" "key_vault_pe" {
  name          = azurerm_key_vault.key_vault.name
  resource_type = "azurerm_private_endpoint"
}

# Create a private endpoint for the SQL Server
resource "azurerm_private_endpoint" "key_vault_pe" {
  name                = azurecaf_name.key_vault_pe.result
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_link_subnet_id

  private_service_connection {
    name                           = azurecaf_name.key_vault_pe.result
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.key_vault.id
    subresource_names              = ["vault"]
  }
}

resource "azurerm_private_dns_a_record" "key_vault-private_dns" {
  name                = lower(azurerm_key_vault.key_vault.name)
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [azurerm_private_endpoint.key_vault_pe.private_service_connection[0].private_ip_address]
}