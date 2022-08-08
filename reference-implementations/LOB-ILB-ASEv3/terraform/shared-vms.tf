data "azurerm_client_config" "current" {
}

# Create the DevOps and Jumpbox VMs
module "shared-vms" {
    source              = "./modules/shared"
    resourceSuffix      = local.resourceSuffix
    resourceGroupName   = azurerm_resource_group.sharedrg.name
    location            = azurerm_resource_group.sharedrg.location
    adminUsername       = var.vmadminUserName
    adminPassword       = var.vmadminPassword
    devOpsVMSubnetId    = local.hubSubnets["CICDAgentSubnetName"]
    jumpboxVMSubnetId   = local.hubSubnets["jumpBoxSubnetName"]
    bastionSubnetId     = local.hubSubnets["AzureBastionSubnet"]
    tenantId            = data.azurerm_client_config.current.tenant_id
    depends_on          = [ azurerm_resource_group.sharedrg, azurerm_resource_group.networkrg ]
}

output "test-vnet" {
  value = azurerm_virtual_network.vnetHub.subnet
}
output "module-shared-vms" {
  value = module.shared-vms.*
}
