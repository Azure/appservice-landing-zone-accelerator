locals{
    tempKeyVaultName  = substr("kv-shared-${var.resourceSuffix}",0, 24)
    keyvaultname      = (substr(local.tempKeyVaultName,1,24) == "-") ? substr(local.tempKeyVaultName, 0, length(local.tempKeyVaultName) - 1): local.tempKeyVaultName
    loganalyticsname  = "log-shared-${var.resourceSuffix}"
    appinsightsname   = "insights-shared-${var.resourceSuffix}"
}

#key vault
resource "azurerm_key_vault" "keyvault" {
  name                        = local.keyvaultname
  location                    = "${var.location}"
  resource_group_name         = "${var.resourceGroupName}"
  enabled_for_disk_encryption = true
  tenant_id                   = "${var.tenantId}"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  /*access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Get",
    ]
    secret_permissions = [
      "Get",
    ]
    storage_permissions = [
      "Get",
    ]
  }*/
}

#log analytics workspace
resource "azurerm_log_analytics_workspace" "loganalytics" {
  name                = local.loganalyticsname
  location            = "${var.location}"
  resource_group_name = "${var.resourceGroupName}"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

#application insights
resource "azurerm_application_insights" "appinsights" {
  name                = local.appinsightsname
  location            = "${var.location}"
  resource_group_name = "${var.resourceGroupName}"
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.loganalytics.id
}

#Devops agent
module "devopsvm" {
    source              = "../winvm"
    vmname              = "devopsvm"
    location            = "${var.location}"
    resourceGroupName   = "${var.resourceGroupName}"
    adminUserName       = "${var.adminUsername}"
    adminPassword       = "${var.adminPassword}"
    cidr                = "${var.devOpsVMSubnetId}"
    installDevOpsAgent  = true
}

#jumpbox
module "jumpboxvm" {
    source                = "../winvm"
    vmname                = "jumpboxvm"
    location              = "${var.location}"
    resourceGroupName     = "${var.resourceGroupName}"
    adminUserName         = "${var.adminUsername}"
    adminPassword         = "${var.adminPassword}"
    cidr                  = "${var.jumpboxVMSubnetId}"
    installDevOpsAgent    = false
}