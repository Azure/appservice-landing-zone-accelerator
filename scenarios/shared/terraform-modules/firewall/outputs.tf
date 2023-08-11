output "private_ip_address" {
  value = azurerm_firewall.firewall.ip_configuration.0.private_ip_address
}

output "firewall_rules" {
  value = local.firewall_rules
} 