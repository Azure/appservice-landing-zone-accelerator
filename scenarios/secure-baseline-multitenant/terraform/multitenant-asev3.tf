
# Create Hub via module
module "hub" {
  source = "./hub"

  application_name = var.application_name
  environment      = var.environment
  location         = var.location
  owner            = var.owner

  # Optional Network Config Variables
  hub_vnet_cidr        = var.hub_vnet_cidr
  spoke_vnet_cidr      = var.spoke_vnet_cidr
  firewall_subnet_name = var.firewall_subnet_name
  firewall_subnet_cidr = var.firewall_subnet_cidr
  bastion_subnet_name  = var.bastion_subnet_name
  bastion_subnet_cidr  = var.bastion_subnet_cidr
  devops_subnet_cidr   = var.devops_subnet_cidr

  # Optional Deployment Variables
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

  entra_admin_group_name      = var.entra_admin_group_name
  entra_admin_group_object_id = var.entra_admin_group_object_id
  appsvc_options              = var.appsvc_options

  # Spoke Network Configuration Variables
  hub_virtual_network      = module.hub.virtual_network
  firewall_private_ip      = module.hub.firewall_private_ip
  firewall_rules           = module.hub.firewall_rules
  spoke_vnet_cidr          = var.spoke_vnet_cidr
  devops_subnet_cidr       = var.devops_subnet_cidr
  appsvc_subnet_cidr       = var.appsvc_subnet_cidr
  front_door_subnet_cidr   = var.front_door_subnet_cidr
  private_link_subnet_cidr = var.private_link_subnet_cidr

  # Optional Self-hosted Agent Config Variables
  vm_admin_username        = var.vm_admin_username
  vm_entra_admin_username  = var.vm_entra_admin_username
  vm_entra_admin_object_id = var.vm_entra_admin_object_id

  # Spoke Resource Configuration Variables
  sql_databases = var.sql_databases

  # Optional Deployment Variables
  deployment_options = var.deployment_options
  global_settings    = var.global_settings
  tags               = var.tags
}
