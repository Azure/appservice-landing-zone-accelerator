output "vnet_id" {
    value = azurerm_virtual_network.spoke_vnet.id
}

output "vnet_name" {
    value = azurerm_virtual_network.spoke_vnet.name
}

output "appsvc_subnet_id" {
    value = azurerm_subnet.appsvc_integration_subnet.id
}

output "frontend_subnet_id" {
    value = azurerm_subnet.afd_integration_subnet.id
}

output "devops_subnet_id" {
    value = azurerm_subnet.devops_subnet.id
}

output "private_link_subnet_id" {
    value = azurerm_subnet.private_link_subnet.id
}

output "azurewebsites_private_dns_zone_id" {
    value = azurerm_private_dns_zone.azurewebsites_dnsprivatezone.id
}

output "azurewebsites_private_dns_zone_name" {
    value = azurerm_private_dns_zone.azurewebsites_dnsprivatezone.name
}

output "sqldb_private_dns_zone_id" {
    value = azurerm_private_dns_zone.sqldb_dnsprivatezone.id
}

output "sqldb_private_dns_zone_name" {
    value = azurerm_private_dns_zone.sqldb_dnsprivatezone.name
}

output "appconfig_private_dns_zone_id" {
    value = azurerm_private_dns_zone.appconfig_dnsprivatezone.id
}

output "appconfig_private_dns_zone_name" {
    value = azurerm_private_dns_zone.appconfig_dnsprivatezone.name
}

output "keyvault_private_dns_zone_id" {
    value = azurerm_private_dns_zone.keyvault_dnsprivatezone.id
}

output "keyvault_private_dns_zone_name" {
    value = azurerm_private_dns_zone.keyvault_dnsprivatezone.name
}

output "redis_private_dns_zone_id" {
    value = azurerm_private_dns_zone.redis_dnsprivatezone.id
}

output "redis_private_dns_zone_name" {
    value = azurerm_private_dns_zone.redis_dnsprivatezone.name
}