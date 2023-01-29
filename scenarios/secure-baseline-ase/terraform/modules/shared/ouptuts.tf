output "instrumentation_key" {
  value     = azurerm_application_insights.appinsights.instrumentation_key
  sensitive = true
}

output "app_id" {
  value = azurerm_application_insights.appinsights.app_id
}

output "vms" {
  value = {
    devopsvm = {
      id                 = module.devopsvm.id
      private_ip_address = module.devopsvm.private_ip_address
    }
    jumpboxvm = {
      id                 = module.jumpboxvm.id
      private_ip_address = module.jumpboxvm.private_ip_address
    }
  }
}
