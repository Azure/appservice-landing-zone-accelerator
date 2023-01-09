terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">=1.2.22"
    }
  }
}

resource "azurecaf_name" "spoke_vnet" {
  name          = var.application_name
  resource_type = "azurerm_virtual_network"
  suffixes      = [var.environment]
}

resource "azurerm_virtual_network" "spoke-vnet" {
  address_space       = var.vnet_cidr
  location            = var.location
  name                = azurecaf_name.spoke_vnet.result
  resource_group_name = var.resource_group
}

resource "azurecaf_name" "app-svc-integration-subnet" {
  name          = "app-svc-integration"
  resource_type = "azurerm_subnet"
  # suffixes      = [var.environment]
}

# https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration
resource "azurerm_subnet" "app-svc-integration-subnet" {
  address_prefixes     = var.appsvc_int_subnet_cidr
  name                 = azurecaf_name.app-svc-integration-subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.spoke-vnet.name

  delegation {
    name = "app-svc-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurecaf_name" "front-door-integration-subnet" {
  name          = "front-door-integration"
  resource_type = "azurerm_subnet"
  # suffixes      = [var.environment]
}

# https://learn.microsoft.com/en-us/azure/app-service/networking/private-endpoint
resource "azurerm_subnet" "front-door-integration-subnet" {
  address_prefixes     = var.front_door_subnet_cidr
  name                 = azurecaf_name.front-door-integration-subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.spoke-vnet.name
}

resource "azurecaf_name" "devops-subnet" {
  name          = "devops"
  resource_type = "azurerm_subnet"
  # suffixes      = [var.environment]
}

resource "azurerm_subnet" "devops-subnet" {
  address_prefixes     = var.devops_subnet_cidr
  name                 = azurecaf_name.devops-subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.spoke-vnet.name
}

resource "azurecaf_name" "private-link-subnet" {
  name          = "private-link"
  resource_type = "azurerm_subnet"
  # suffixes      = [var.environment]
}

resource "azurerm_subnet" "private-link-subnet" {
  address_prefixes     = var.private_link_subnet_cidr
  name                 = azurecaf_name.private-link-subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.spoke-vnet.name
}

resource "azurerm_private_dns_zone" "azurewebsites-dnsprivatezone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "azurewebsites-spoke-dnszonelink" {
  name                  = "privatelink.azurewebsites.net"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.azurewebsites-dnsprivatezone.name
  virtual_network_id    = azurerm_virtual_network.spoke-vnet.id
}

resource "azurerm_private_dns_zone" "sqldb-dnsprivatezone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "sqldb-spoke-dnszonelink" {
  name                  = "privatelink.database.windows.net"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.sqldb-dnsprivatezone.name
  virtual_network_id    = azurerm_virtual_network.spoke-vnet.id
}

resource "azurerm_private_dns_zone" "appconfig-dnsprivatezone" {
  name                = "privatelink.azconfig.io"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "appconfig-spoke-dnszonelink" {
  name                  = "privatelink.azconfig.io"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.appconfig-dnsprivatezone.name
  virtual_network_id    = azurerm_virtual_network.spoke-vnet.id
}

resource "azurerm_private_dns_zone" "keyvault-dnsprivatezone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault-spoke-dnszonelink" {
  name                  = "privatelink.vaultcore.azure.net"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.keyvault-dnsprivatezone.name
  virtual_network_id    = azurerm_virtual_network.spoke-vnet.id
}

resource "azurerm_private_dns_zone" "redis-dnsprivatezone" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis-spoke-dnszonelink" {
  name                  = "privatelink.redis.cache.windows.net"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.redis-dnsprivatezone.name
  virtual_network_id    = azurerm_virtual_network.spoke-vnet.id
}

resource "azurecaf_name" "route-table" {
  name          = var.application_name
  resource_type = "azurerm_route_table"
  suffixes      = [var.environment]
}

resource "azurerm_route_table" "route-table" {
  name                          = azurecaf_name.route-table.result
  location                      = var.location
  resource_group_name           = var.resource_group
  disable_bgp_route_propagation = false

  tags = {
    environment = var.environment
  }
}

resource "azurerm_route" "default-route" {
  name                   = "defaultRoute"
  resource_group_name    = var.resource_group
  route_table_name       = azurerm_route_table.route-table.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

resource "azurerm_subnet_route_table_association" "route_table_association" {
  subnet_id      = azurerm_subnet.app-svc-integration-subnet.id
  route_table_id = azurerm_route_table.route-table.id
}
