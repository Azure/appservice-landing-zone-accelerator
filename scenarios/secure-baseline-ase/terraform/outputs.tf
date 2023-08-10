output "app_service_name" {
  value = module.app_service.web_app_name
}

output "app_service_default_hostname" {
  value = module.app_service.web_app_hostname
}

# -----------------------------------------------------------------------
# Networking (network.tf)
# -----------------------------------------------------------------------
output "hubVNet" {
  description = "Name of the provisioned Hub virtual network."
  value = {
    name    = module.vnetHub.vnet_name
    id      = module.vnetHub.vnet_id
    subnets = module.vnetHub.subnets
  }
}

# -----------------------------------------------------------------------
# ASE (ase.tf) Values will only populate if create_new_ase is true
# -----------------------------------------------------------------------
output "spokeVNet" {
  description = "Name of the provisioned Hub virtual network."
  value = local.create_new_ase ? {
    name    = module.vnetSpoke[0].vnet_name
    id      = module.vnetSpoke[0].vnet_id
    subnets = module.vnetSpoke[0].subnets
  } : null
}

output "aseName" {
  description = "Name of the App Service Environment."
  value       = local.ase.name
}

output "aseId" {
  description = "ID of the App Service Environment."
  value       = local.ase.id
}


# -----------------------------------------------------------------------
# Shared-VMs (shared-vms.tf)
# -----------------------------------------------------------------------
output "shared-vms" {
  description = "Private IP Addresses and IDs of the provisioned shared virtual machines (DevOps and Jumpbox VMs)."
  value = var.deployment_options.deploy_vm ? {
    devops = {
      ip = module.devops_vm[0].private_ip_address
      id = module.devops_vm[0].id
    }
    jumpbox = {
      ip = module.jumpbox_vm[0].private_ip_address
      id = module.jumpbox_vm[0].id
    }
  } : {}
}