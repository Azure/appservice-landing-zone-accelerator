# module "shared" {
#     source              = "./modules/shared"
#     resourceSuffix      = local.resourceSuffix
#     # resourceGroupName   = local.sharedResourceGroupName
#     resourceGroupName = azurerm_resource_group.sharedrg.name
#     adminUsername       = var.vmadminUserName
#     adminPassword       = var.vmadminPassword
#     devOpsVMSubnetId    = "${azurerm_virtual_network.vnetHub.id}/subnets/CICDAgentSubnetName"
#     jumpboxVMSubnetId   = "${azurerm_virtual_network.vnetHub.id}/subnets/jumpBoxSubnetName"
#     bastionSubnetId     = "${azurerm_virtual_network.vnetHub.id}/subnets/AzureBastionSubnet"
#     # location            = var.location
#     location            = azurerm_resource_group.sharedrg.location
#     tenantId            =  data.azurerm_client_config.current.tenant_id
#     depends_on          = [azurerm_resource_group.sharedrg, azurerm_resource_group.networkrg ]
# }

output "test-vnet" {
  value = azurerm_virtual_network.vnetHub.subnet
}
output "testAzureBastionSubnet" {
  value = local.hubSubnets
}
