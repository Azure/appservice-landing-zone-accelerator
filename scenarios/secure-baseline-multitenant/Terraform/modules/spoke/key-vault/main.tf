provider "azurerm" {
  features {}
}
data "azurerm_resource_group" "spoke-rg" {
  name = var.resource_group
}

resource "azurerm_key_vault" "secure-baseline-app-service-kv" {
  name                        = "keyvault-${var.application_name}-${var.environment}"
  resource_group_name = data.azurerm_resource_group.spoke-rg.name
  location            = data.azurerm_resource_group.spoke-rg.location
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = var.sku_name

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = var.app_svc_managed_id
    key_permissions = [
      "Get",
    ]
    secret_permissions = [
      "Get", "List"
    ]

  }
}

# Create a private endpoint for the KV
resource "azurerm_private_endpoint" "kv-private-endpoint" {
  name                = "kv-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.private-link-subnet-id
}
