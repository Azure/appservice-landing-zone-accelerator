output "vnet_id" {
    value = azurerm_virtual_network.spoke-vnet.id
}

output "vnet_name" {
    value = azurerm_virtual_network.spoke-vnet.name
}

output "app_svc_integration_subnet_id" {
    value = azurerm_subnet.app-svc-integration-subnet.id
}

output "front_door_integration_subnet_id" {
    value = azurerm_subnet.front-door-integration-subnet.id
}

output "devops_subnet_id" {
    value = azurerm_subnet.devops-subnet.id
}

output "private_link_subnet_id" {
    value = azurerm_subnet.private-link-subnet.id
}

output "azurewebsites_private_dns_zone_id" {
    value = azurerm_private_dns_zone.azurewebsites-dnsprivatezone.id
}

output "sqldb_private_dns_zone_id" {
    value = azurerm_private_dns_zone.sqldb-dnsprivatezone.id
}

output "sqldb_private_dns_zone_name" {
    value = azurerm_private_dns_zone.sqldb-dnsprivatezone.name
}

output "appconfig_private_dns_zone_id" {
    value = azurerm_private_dns_zone.appconfig-dnsprivatezone.id
}

output "appconfig_private_dns_zone_name" {
    value = azurerm_private_dns_zone.appconfig-dnsprivatezone.name
}

output "keyvault_private_dns_zone_id" {
    value = azurerm_private_dns_zone.keyvault-dnsprivatezone.id
}

output "keyvault_private_dns_zone_name" {
    value = azurerm_private_dns_zone.keyvault-dnsprivatezone.name
}

output "redis_private_dns_zone_id" {
    value = azurerm_private_dns_zone.redis-dnsprivatezone.id
}

output "redis_private_dns_zone_name" {
    value = azurerm_private_dns_zone.redis-dnsprivatezone.name
}