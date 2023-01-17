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

resource "azurerm_virtual_network" "spoke_vnet" {
  address_space       = var.vnet_cidr
  location            = var.location
  name                = azurecaf_name.spoke_vnet.result
  resource_group_name = var.resource_group
}

resource "azurecaf_name" "appsvc_integration_subnet" {
  name          = "appsvc-integration"
  resource_type = "azurerm_subnet"
  # suffixes      = [var.environment]
}

# https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration
resource "azurerm_subnet" "appsvc_integration_subnet" {
  address_prefixes     = var.appsvc_int_subnet_cidr
  name                 = azurecaf_name.appsvc_integration_subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name

  delegation {
    name = "app-svc-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurecaf_name" "afd_integration_subnet" {
  name          = "afd-integration"
  resource_type = "azurerm_subnet"
  # suffixes      = [var.environment]
}

# https://learn.microsoft.com/en-us/azure/app-service/networking/private-endpoint
resource "azurerm_subnet" "afd_integration_subnet" {
  address_prefixes     = var.front_door_subnet_cidr
  name                 = azurecaf_name.afd_integration_subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
}

resource "azurecaf_name" "devops_subnet" {
  name          = "devops"
  resource_type = "azurerm_subnet"
  # suffixes      = [var.environment]
}

resource "azurerm_subnet" "devops_subnet" {
  address_prefixes     = var.devops_subnet_cidr
  name                 = azurecaf_name.devops_subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
}

resource "azurecaf_name" "private_link_subnet" {
  name          = "private-link"
  resource_type = "azurerm_subnet"
  # suffixes      = [var.environment]
}

resource "azurerm_subnet" "private_link_subnet" {
  address_prefixes     = var.private_link_subnet_cidr
  name                 = azurecaf_name.private_link_subnet.result
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
}

resource "azurerm_private_dns_zone" "azurewebsites_dnsprivatezone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "azurewebsites_spoke_dnszonelink" {
  name                  = "privatelink.azurewebsites.net"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.azurewebsites_dnsprivatezone.name
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_private_dns_zone" "sqldb_dnsprivatezone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "sqldb_spoke_dnszonelink" {
  name                  = "privatelink.database.windows.net"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.sqldb_dnsprivatezone.name
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_private_dns_zone" "appconfig_dnsprivatezone" {
  name                = "privatelink.azconfig.io"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "appconfig_spoke_dnszonelink" {
  name                  = "privatelink.azconfig.io"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.appconfig_dnsprivatezone.name
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_private_dns_zone" "keyvault_dnsprivatezone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault_spoke_dnszonelink" {
  name                  = "privatelink.vaultcore.azure.net"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.keyvault_dnsprivatezone.name
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_private_dns_zone" "redis_dnsprivatezone" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis_spoke_dnszonelink" {
  name                  = "privatelink.redis.cache.windows.net"
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.redis_dnsprivatezone.name
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}

resource "azurecaf_name" "route_table" {
  name          = var.application_name
  resource_type = "azurerm_route_table"
  suffixes      = [var.environment]
}

resource "azurerm_route_table" "route_table" {
  name                          = azurecaf_name.route_table.result
  location                      = var.location
  resource_group_name           = var.resource_group
  disable_bgp_route_propagation = false

  tags = {
    environment = var.environment
  }
}

resource "azurerm_route" "default_route" {
  count = var.deployment_options.enable_egress_lockdown ? 1 : 0

  name                   = "defaultRoute"
  resource_group_name    = var.resource_group
  route_table_name       = azurerm_route_table.route_table.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}

resource "azurerm_subnet_route_table_association" "appsvc_udr_association" {
  subnet_id      = azurerm_subnet.appsvc_integration_subnet.id
  route_table_id = azurerm_route_table.route_table.id
}

resource "azurerm_subnet_route_table_association" "devops_udr_association" {
  subnet_id      = azurerm_subnet.devops_subnet.id
  route_table_id = azurerm_route_table.route_table.id
}
