output "name" {
  value = azurerm_windows_virtual_machine.vm.name
}

output "id" {
  value = azurerm_windows_virtual_machine.vm.id
}

output "private_ip_address" {
  value = azurerm_windows_virtual_machine.vm.private_ip_address
}

output "principal_id" {
  value = azurerm_windows_virtual_machine.vm.identity.0.principal_id
}

output "vm_key_vault_secret_ids" {
  value = var.key_vault_id == null ? {} : {
    "admin_username" = azurerm_key_vault_secret.admin_username
    "admin_password" = azurerm_key_vault_secret.admin_password
  }
}