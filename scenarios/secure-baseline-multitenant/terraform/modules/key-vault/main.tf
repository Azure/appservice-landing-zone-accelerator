terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.23"
    }
  }
}

resource "azurecaf_name" "key_vault" {
  name          = "appsvc"
  resource_type = "azurerm_key_vault"
  suffixes      = [var.environment, var.unique_id]
}

resource "azurerm_key_vault" "this" {
  name                          = azurecaf_name.key_vault.result
  resource_group_name           = var.resource_group
  location                      = var.location
  tenant_id                     = var.tenant_id
  sku_name                      = var.sku_name
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  public_network_access_enabled = false
  enabled_for_disk_encryption   = true
  enable_rbac_authorization     = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_role_assignment" "secrets_user" {
  count = length(var.secret_reader_identities)

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.secret_reader_identities[count.index]
}

// https://github.com/hashicorp/terraform-provider-azurerm/issues/9738

resource "azurerm_role_assignment" "secrets_officer" {
  count = length(var.secret_officer_identities)

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.secret_officer_identities[count.index]
}

resource "azurecaf_name" "private_endpoint" {
  name          = azurerm_key_vault.this.name
  resource_type = "azurerm_private_endpoint"
}

resource "azurerm_private_endpoint" "this" {
  name                = azurecaf_name.private_endpoint.result
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private_link_subnet_id

  private_service_connection {
    name                           = azurecaf_name.private_endpoint.result
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
  }
}

resource "azurerm_private_dns_a_record" "this" {
  name                = lower(azurerm_key_vault.this.name)
  zone_name           = var.private_dns_zone.name
  resource_group_name = var.private_dns_zone.resource_group
  ttl                 = 300
  records             = [azurerm_private_endpoint.this.private_service_connection[0].private_ip_address]
}
