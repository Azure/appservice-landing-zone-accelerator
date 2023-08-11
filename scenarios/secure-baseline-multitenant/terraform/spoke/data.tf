data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.hub_state_resource_group_name
    storage_account_name = var.hub_state_storage_account_name
    container_name       = var.hub_state_container_name
    key                  = var.hub_state_key
  }
}

data "azurerm_virtual_network" "hub" {
  name                = data.terraform_remote_state.hub.outputs.vnet_name
  resource_group_name = data.terraform_remote_state.hub.outputs.rg_name
}
