# # output "app_service_name" {
# #   value = azurerm_app_service.main.name
# # }

# # output "app_service_default_hostname" {
# #   value = "https://${azurerm_app_service.main.default_site_hostname}"
# # }


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


# # -----------------------------------------------------------------------
# # Shared-VMs (shared-vms.tf)
# # -----------------------------------------------------------------------
# output "shared-vms" {
#   description = "Private IP Addresses and IDs of the provisioned shared virtual machines (DevOps and Jumpbox VMs)."
#   value       = module.shared-vms.vms
# }