locals {
  tempKeyVaultName = substr("kv-shared-${var.resourceSuffix}", 0, 24)
  keyvaultname     = (substr(local.tempKeyVaultName, 1, 24) == "-") ? substr(local.tempKeyVaultName, 0, length(local.tempKeyVaultName) - 1) : local.tempKeyVaultName
  loganalyticsname = "log-shared-${var.resourceSuffix}"
  appinsightsname  = "insights-shared-${var.resourceSuffix}"
}

data "azurerm_client_config" "current" {}

#key vault
resource "azurerm_key_vault" "keyvault" {
  name                        = local.keyvaultname
  location                    = var.location
  resource_group_name         = var.resourceGroupName
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenantId
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Get",
      "List",
      "Update"
    ]
    secret_permissions = [
      "Get",
      "Set",
      "List",
      "Recover",
      "Delete",
      "Purge"
    ]
    storage_permissions = [
      "Get",
      "Set",
      "Update"
    ]
  }
}

#log analytics workspace
resource "azurerm_log_analytics_workspace" "loganalytics" {
  name                = local.loganalyticsname
  location            = var.location
  resource_group_name = var.resourceGroupName
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

#application insights
resource "azurerm_application_insights" "appinsights" {
  name                = local.appinsightsname
  location            = var.location
  resource_group_name = var.resourceGroupName
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.loganalytics.id
}

resource "random_password" "password" {
  count            = var.adminPassword == null ? 2 : 0
  length           = 16
  special          = true
  override_special = "!#$%&*?"
}

#Devops agent
module "devopsvm" {
  source             = "../winvm"
  vmname             = "asedevopsvm"
  location           = var.location
  resourceGroupName  = var.resourceGroupName
  adminUserName      = var.adminUsername
  adminPassword      = var.adminPassword == null ? random_password.password.0.result : var.adminPassword
  cidr               = var.devOpsVMSubnetId
  installDevOpsAgent = false
}

#jumpbox
module "jumpboxvm" {
  source             = "../winvm"
  vmname             = "asejumpboxvm"
  location           = var.location
  resourceGroupName  = var.resourceGroupName
  adminUserName      = var.adminUsername
  adminPassword      = var.adminPassword == null ? random_password.password.1.result : var.adminPassword
  cidr               = var.jumpboxVMSubnetId
  installDevOpsAgent = false
}

# If no VM password is provided, store the generated passwords into the Key Vault as secrets
resource "azurerm_key_vault_secret" "devopsvm_password" {
  count        = var.adminPassword == null ? 1 : 0
  name         = module.devopsvm.name
  value        = random_password.password.0.result
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "jumpboxvm_password" {
  count        = var.adminPassword == null ? 1 : 0
  name         = module.jumpboxvm.name
  value        = random_password.password.1.result
  key_vault_id = azurerm_key_vault.keyvault.id
}