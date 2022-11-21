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