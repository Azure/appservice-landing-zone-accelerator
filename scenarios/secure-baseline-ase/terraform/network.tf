
module "vnetHub" {
  source = "../../shared/terraform-modules/network"

  global_settings = local.global_settings
  resource_group  = azurerm_resource_group.network.name
  location        = azurerm_resource_group.network.location
  name            = var.application_name
  vnet_cidr       = var.hubVNetNameAddressPrefix

  subnets = [
    {
      name        = "AzureBastionSubnet"
      subnet_cidr = var.bastionAddressPrefix
      delegation  = null
    },
    {
      name        = "jumpBoxSubnetName"
      subnet_cidr = var.jumpBoxAddressPrefix
      delegation  = null
    },
    {
      name        = "CICDAgentSubnetName"
      subnet_cidr = var.CICDAgentNameAddressPrefix
      delegation  = null
    }
  ]

  tags = local.base_tags
}

module "bastion" {
  count = var.deployment_options.deploy_bastion ? 1 : 0

  source = "../../shared/terraform-modules/bastion"

  global_settings = local.global_settings
  name            = var.application_name

  # Retrieve the subnet id by a lookup on subnet name from the list of subnets in the module output
  subnet_id      = module.vnetHub.subnets["AzureBastionSubnet"].id
  resource_group = azurerm_resource_group.network.name
  location       = azurerm_resource_group.network.location

  tags = local.base_tags
}


# locals {
#   // Variables
#   bastionHostName     = "snet-basthost-${local.resourceSuffix}"
#   bastionHostPip      = "${local.bastionHostName}-pip"
#   hubVNetName         = "vnet-hub-${local.resourceSuffix}"
#   spokeVNetName       = "vnet-spoke-${local.resourceSuffix}"
#   bastionSubnetName   = "AzureBastionSubnet"
#   CICDAgentSubnetName = "snet-cicd-${local.resourceSuffix}"
#   jumpBoxSubnetName   = "snet-jbox-${local.resourceSuffix}"
#   aseSubnetName       = "snet-ase-${local.resourceSuffix}"

#   hubSubnets = { for subnet in azurerm_virtual_network.vnetHub.subnet : subnet.name => subnet.id }
# }

# // Resources - VNet - SubNets
# resource "azurerm_virtual_network" "vnetHub" {
#   name                = local.hubVNetName
#   location            = azurerm_resource_group.networkrg.location
#   resource_group_name = azurerm_resource_group.networkrg.name
#   address_space       = [var.hubVNetNameAddressPrefix]

#   subnet {
#     name           = "AzureBastionSubnet"
#     address_prefix = var.bastionAddressPrefix
#   }

#   subnet {
#     name           = "jumpBoxSubnetName"
#     address_prefix = var.jumpBoxAddressPrefix
#   }

#   subnet {
#     name           = "CICDAgentSubnetName"
#     address_prefix = var.CICDAgentNameAddressPrefix
#   }

#   depends_on = [azurerm_resource_group.networkrg]

# }


# // Resources - VNet - SubNets - Spoke
# resource "azurerm_virtual_network" "vnetSpoke" {
#   name                = local.spokeVNetName
#   location            = azurerm_resource_group.networkrg.location
#   resource_group_name = azurerm_resource_group.networkrg.name
#   address_space       = [var.spokeVNetNameAddressPrefix]
#   depends_on          = [azurerm_resource_group.networkrg]
# }

# resource "azurerm_subnet" "vnetSpokeSubnet" {
#   name                 = local.aseSubnetName
#   resource_group_name  = azurerm_resource_group.networkrg.name
#   virtual_network_name = azurerm_virtual_network.vnetSpoke.name
#   address_prefixes     = [var.aseAddressPrefix]

#   delegation {
#     name = "hostingEnvironment"

#     service_delegation {
#       name    = "Microsoft.Web/hostingEnvironments"
#       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
#     }
#   }
#   depends_on = [azurerm_virtual_network.vnetSpoke]
# }

# // Peering
# resource "azurerm_virtual_network_peering" "peerhubtospoke" {
#   name                         = "peerhubtospoke"
#   resource_group_name          = azurerm_resource_group.networkrg.name
#   virtual_network_name         = azurerm_virtual_network.vnetHub.name
#   remote_virtual_network_id    = azurerm_virtual_network.vnetSpoke.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = false
#   allow_gateway_transit        = false
#   use_remote_gateways          = false
#   depends_on                   = [azurerm_virtual_network.vnetHub, azurerm_virtual_network.vnetSpoke]
# }

# resource "azurerm_virtual_network_peering" "peerspoketohub" {
#   name                         = "peerspoketohub"
#   resource_group_name          = azurerm_resource_group.networkrg.name
#   virtual_network_name         = azurerm_virtual_network.vnetSpoke.name
#   remote_virtual_network_id    = azurerm_virtual_network.vnetHub.id
#   allow_virtual_network_access = true
#   allow_forwarded_traffic      = false
#   allow_gateway_transit        = false
#   use_remote_gateways          = false
#   depends_on                   = [azurerm_virtual_network.vnetHub, azurerm_virtual_network.vnetSpoke]
# }

# //bastionHost
# resource "azurerm_public_ip" "bastionHostPippublicIp" {
#   name                = local.bastionHostPip
#   resource_group_name = azurerm_resource_group.networkrg.name
#   location            = azurerm_resource_group.networkrg.location
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   depends_on          = [azurerm_resource_group.networkrg]
# }

# resource "azurerm_bastion_host" "bastionHost" {
#   name                = local.bastionHostName
#   location            = azurerm_resource_group.networkrg.location
#   resource_group_name = azurerm_resource_group.networkrg.name

#   ip_configuration {
#     name                 = "IpConf"
#     subnet_id            = "${azurerm_virtual_network.vnetHub.id}/subnets/AzureBastionSubnet"
#     public_ip_address_id = azurerm_public_ip.bastionHostPippublicIp.id
#   }
#   depends_on = [azurerm_virtual_network.vnetHub, azurerm_virtual_network.vnetSpoke]
# }

