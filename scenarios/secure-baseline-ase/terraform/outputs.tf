# output "app_service_name" {
#   value = azurerm_app_service.main.name
# }

# output "app_service_default_hostname" {
#   value = "https://${azurerm_app_service.main.default_site_hostname}"
# }


# -----------------------------------------------------------------------
# App Service Environment (ase.tf)
# -----------------------------------------------------------------------
output "aseName" {
  description = "Name of the App Service Environment."
  value       = azurerm_app_service_environment_v3.ase.name
}
output "aseId" {
  description = "ID of the App Service Environment."
  value       = azurerm_app_service_environment_v3.ase.id
}
output "appServicePlanName" {
  description = "Name of the App Service Plan."
  value       = azurerm_service_plan.appServicePlan.name
}
output "appServicePlanId" {
  description = "ID of the App Service Plan."
  value       = azurerm_service_plan.appServicePlan.id
}

# -----------------------------------------------------------------------
# Networking (network.tf)
# -----------------------------------------------------------------------
output "hubVNetName" {
  description = "Name of the provisioned Hub virtual network."
  value       = azurerm_virtual_network.vnetHub.name
}

output "spokeVNetName" {
  description = "Name of the provisioned Spoke virtual network."
  value       = azurerm_virtual_network.vnetSpoke.name
}

output "hubVNetId" {
  description = "ID of the provisioned Hub virtual network."
  value       = azurerm_virtual_network.vnetHub.id
}

output "spokeVNetId" {
  description = "ID of the provisioned Spoke virtual network."
  value       = azurerm_virtual_network.vnetSpoke.id
}

output "hubSubnets" {
  description = "Hub virtual network subnet name-to-id mapping."
  value       = local.hubSubnets
}

# -----------------------------------------------------------------------
# Shared-VMs (shared-vms.tf)
# -----------------------------------------------------------------------
output "shared-vms" {
  description = "Private IP Addresses and IDs of the provisioned shared virtual machines (DevOps and Jumpbox VMs)."
  value       = module.shared-vms.vms
}