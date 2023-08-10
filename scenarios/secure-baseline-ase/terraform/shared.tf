module "devops_vm" {
  count = var.deployment_options.deploy_vm ? 1 : 0

  source = "../../shared/terraform-modules/windows-vm"

  resource_group      = azurerm_resource_group.shared.name
  vm_name             = "devops"
  location            = var.location
  vm_subnet_id        = module.vnetHub.subnets["CICDAgentSubnet"].id
  admin_username      = var.vmAdminUsername
  admin_password      = var.vmAdminPassword
  aad_admin_username  = var.vm_aad_admin_username
  aad_admin_object_id = var.vm_aad_admin_object_id
  global_settings     = local.global_settings

  tags = local.base_tags

  identity = {
    type = "SystemAssigned"
  }
}


module "jumpbox_vm" {
  count = var.deployment_options.deploy_vm ? 1 : 0

  source = "../../shared/terraform-modules/windows-vm"

  resource_group = azurerm_resource_group.shared.name
  vm_name        = "jumpbox"
  location       = var.location
  vm_subnet_id   = module.vnetHub.subnets["JumpBoxSubnet"].id
  admin_username = var.vmAdminUsername
  admin_password = var.vmAdminPassword
  # aad_admin_username  = var.vm_aad_admin_username
  aad_admin_object_id = var.vm_aad_admin_object_id
  global_settings     = local.global_settings

  tags = local.base_tags

  identity = {
    type = "SystemAssigned"
  }
}
