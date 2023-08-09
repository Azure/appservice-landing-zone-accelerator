
module "vnetHub" {
  source = "../../shared/terraform-modules/network"

  global_settings = local.global_settings
  resource_group  = azurerm_resource_group.network.name
  location        = azurerm_resource_group.network.location
  name            = "${var.application_name}-hub"
  vnet_cidr       = var.hubVNetNameAddressPrefix

  subnets = [
    {
      name        = "AzureBastionSubnet"
      subnet_cidr = var.bastionAddressPrefix
      delegation  = null
    },
    {
      name        = "JumpBoxSubnet"
      subnet_cidr = var.jumpBoxAddressPrefix
      delegation  = null
    },
    {
      name        = "CICDAgentSubnet"
      subnet_cidr = var.CICDAgentNameAddressPrefix
      delegation  = null
    }
  ]

  tags = local.base_tags
}

module "bastion" {
  count = var.deployment_options.deploy_bastion ? 1 : 0

  source = "../../shared/terraform-modules/bastion"

  global_settings = local.global_settings
  name            = var.application_name

  # Retrieve the subnet id by a lookup on subnet name from the list of subnets in the module output
  subnet_id      = module.vnetHub.subnets["AzureBastionSubnet"].id
  resource_group = azurerm_resource_group.network.name
  location       = azurerm_resource_group.network.location

  tags = local.base_tags
}
