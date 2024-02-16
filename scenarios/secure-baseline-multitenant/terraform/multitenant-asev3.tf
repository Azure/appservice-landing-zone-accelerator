
# Create Hub via module
module "hub" {
  source = "./hub"

  application_name = var.application_name
  environment      = var.environment
  location         = var.location
  owner            = var.owner

  deployment_options = var.deployment_options
  global_settings    = var.global_settings
  tags               = var.tags
}

module "spoke" {
  source = "./spoke"

  application_name = var.application_name
  environment      = var.environment
  location         = var.location
  owner            = var.owner
  tenant_id        = var.tenant_id

  hub_vnet_settings = {
    resource_group_name = module.hub.rg_name
    name                = module.hub.vnet_name

    firewall = {
      private_ip = module.hub.firewall_private_ip
    }
  }

  ##
  entra_admin_group_name      = var.entra_admin_group_name
  entra_admin_group_object_id = var.entra_admin_group_object_id

  vm_entra_admin_object_id = var.vm_entra_admin_object_id

}

# Create Spoke via module
module "spoke" {
  source = "./spoke"

  application_name = var.application_name
  environment      = var.environment
  location         = var.location
  owner            = var.owner
  tenant_id        = var.tenant_id

  spoke_vnet_cidr          = var.spoke_vnet_cidr
  devops_subnet_cidr       = var.devops_subnet_cidr
  appsvc_subnet_cidr       = var.appsvc_subnet_cidr
  front_door_subnet_cidr   = var.front_door_subnet_cidr
  private_link_subnet_cidr = var.private_link_subnet_cidr
  vm_admin_password        = var.vm_admin_password
  vm_admin_username        = var.vm_admin_username
  vm_entra_admin_username  = var.vm_entra_admin_username

  deployment_options = var.deployment_options

  global_settings = var.global_settings
  tags            = var.tags

  entra_admin_group_name      = var.entra_admin_group_name
  entra_admin_group_object_id = var.entra_admin_group_object_id

  vm_entra_admin_object_id = var.vm_entra_admin_object_id

  depends_on = [
    module.hub
  ]
}