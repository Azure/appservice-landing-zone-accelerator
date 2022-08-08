output "instrumentation_key" {
  value = azurerm_application_insights.appinsights.instrumentation_key
  sensitive = true
}

output "app_id" {
  value = azurerm_application_insights.appinsights.app_id
}

output "jumpbox_vm_id" {
  value = module.jumpboxvm.id
}
output "devops_vm_id" {
  value = module.devopsvm.id
}
output "jumpbox_vm_private_ip" {
  value = module.jumpboxvm.private_ip_address
}
output "devops_vm_private_ip" {
  value = module.devopsvm.private_ip_address
}