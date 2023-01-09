output "private_ip_address" {
  value = azurerm_firewall.firewall-standard.ip_configuration.0.private_ip_address
}
