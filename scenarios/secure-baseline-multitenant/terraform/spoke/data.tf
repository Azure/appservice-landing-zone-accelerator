# Lookup the Hub VNet by either the `hub_remote_state_settings` or the `hub_vnet_settings` variables
#   If both are provided, hub_vnet_settings will be used.
data "terraform_remote_state" "hub" {
  count   = var.hub_vnet_settings == null ? 1 : 0
  backend = "azurerm"
  config  = var.hub_remote_state_settings
}

data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_settings == null ? data.terraform_remote_state.hub[0].outputs.vnet_name : var.hub_vnet_settings.name
  resource_group_name = var.hub_vnet_settings == null ? data.terraform_remote_state.hub[0].outputs.rg_name : var.hub_vnet_settings.resource_group_name
}
