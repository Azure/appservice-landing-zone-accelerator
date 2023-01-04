terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "key-vault" {
  name          = "appsvc"
  resource_type = "azurerm_key_vault"
  suffixes      = [var.environment, var.unique_id]
}

resource "azurerm_key_vault" "key-vault" {
  name                          = azurecaf_name.key-vault.result
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
}

resource "azurecaf_name" "key-vault-private-endpoint" {
  name          = azurerm_key_vault.key-vault.name
  resource_type = "azurerm_private_endpoint"
  suffixes      = [var.environment]
}

# Create a private endpoint for the SQL Server
resource "azurerm_private_endpoint" "key-vault-private-endpoint" {
  name                = azurecaf_name.key-vault-private-endpoint.result
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_link_subnet_id

  private_service_connection {
    name                           = azurecaf_name.key-vault-private-endpoint.result
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.key-vault.id
    subresource_names              = ["vault"]
  }
}

resource "azurerm_private_dns_a_record" "kay-vault-private-dns" {
  name                = lower(azurerm_key_vault.key-vault.name)
  zone_name           = var.private_dns_zone_name
  resource_group_name = var.resource_group
  ttl                 = 300
  records             = [azurerm_private_endpoint.key-vault-private-endpoint.private_service_connection[0].private_ip_address]
}