# Hub network config

resource "azurecaf_name" "caf_name_hub_rg" {
  name          = var.application_name
  resource_type = "azurerm_resource_group"
  prefixes      = local.global_settings.prefixes
  random_length = local.global_settings.random_length
  clean_input   = true
  passthrough   = local.global_settings.passthrough
  use_slug      = local.global_settings.use_slug
}

resource "azurerm_resource_group" "hub" {
  name     = azurecaf_name.caf_name_hub_rg.result
  location = var.location

  tags = local.base_tags
}

module "network" {
  source = "../../../shared/terraform-modules/network"

  global_settings = local.global_settings
  name            = var.application_name
  resource_group  = azurerm_resource_group.hub.name
  location        = azurerm_resource_group.hub.location
  vnet_cidr       = var.hub_vnet_cidr

  subnets = [
    {
      name        = var.firewall_subnet_name
      subnet_cidr = var.firewall_subnet_cidr
      delegation  = null
    },
    {
      name        = var.bastion_subnet_name
      subnet_cidr = var.bastion_subnet_cidr
      delegation  = null
  }]

  tags = local.base_tags
}

module "firewall" {
  count = var.deployment_options.enable_egress_lockdown ? 1 : 0

  source = "../../../shared/terraform-modules/firewall"

  global_settings = local.global_settings
  name            = var.application_name

  # Retrieve the subnet id by a lookup on subnet name from the list of subnets in the module output
  subnet_id      = module.network.subnets[var.firewall_subnet_name].id
  resource_group = azurerm_resource_group.hub.name
  location       = azurerm_resource_group.hub.location

  firewall_rules_source_addresses = concat(var.hub_vnet_cidr, var.spoke_vnet_cidr)
  devops_subnet_cidr              = var.devops_subnet_cidr

  tags = local.base_tags
}

module "bastion" {
  count = var.deployment_options.deploy_bastion ? 1 : 0

  source = "../../../shared/terraform-modules/bastion"

  global_settings = local.global_settings
  name            = var.application_name

  # Retrieve the subnet id by a lookup on subnet name from the list of subnets in the module output
  subnet_id      = module.network.subnets[var.bastion_subnet_name].id
  resource_group = azurerm_resource_group.hub.name
  location       = azurerm_resource_group.hub.location

  tags = local.base_tags

  depends_on = [module.firewall]
}
