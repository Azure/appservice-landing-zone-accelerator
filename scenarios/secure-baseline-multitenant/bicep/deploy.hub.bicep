targetScope = 'resourceGroup'

// reference to the BICEP naming module
param naming object

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

@description('Resource tags that we might need to add to all resources (i.e. Environment Cost center application name etc)')
param tags object

@description('CIDR of the HUB vnet i.e. 192.168.0.0/24')
param vnetHubAddressSpace string

@description('CIDR of the subnet hosting the azure Firewall')
param subnetHubFirewallAddressSpace string

@description('CIDR to use for the AzureFirewallManagementSubnet, which is required by AzFW Basic.')
param subnetHubFirewallManagementAddressSpace string

@description('CIDR of the subnet hosting the Bastion Service')
param subnetHubBastionAddressSpace string

@description('CIDR of the SPOKE vnet i.e. 192.168.0.0/24')
param vnetSpokeAddressSpace string

@description('CIDR of the subnet that will hold devOps agents etc ')
param subnetSpokeDevOpsAddressSpace string


var resourceNames = {
  bastionService: naming.bastionHost.name
  laws: take ('${naming.logAnalyticsWorkspace.name}-hub', 63)
  azFw: naming.firewall.name
  vnetHub: take('${naming.virtualNetwork.name}-hub', 80)
  subnetFirewall: 'AzureFirewallSubnet'
  subnetFirewallManagement: 'AzureFirewallManagementSubnet'
  subnetBastion: 'AzureBastionSubnet'
}

var subnets = [ 
  {
    name: resourceNames.subnetFirewall
    properties: {
      addressPrefix: subnetHubFirewallAddressSpace
      privateEndpointNetworkPolicies: 'Disabled'  
      // networkSecurityGroup: {
      //   id: nsgAca.outputs.nsgID
      // } 
    } 
  }
  {
    name: resourceNames.subnetFirewallManagement
    properties: {
      addressPrefix: subnetHubFirewallManagementAddressSpace 
    }
  }
  {
    name: resourceNames.subnetBastion
    properties: {
      addressPrefix: subnetHubBastionAddressSpace
      privateEndpointNetworkPolicies: 'Disabled'    
    }
  }
]


module vnetHub '../../shared/bicep/network/vnet.bicep' = {
  name: 'vnetHub-Deployment'
  params: {
    location: location
    name: resourceNames.vnetHub
    subnetsInfo: subnets
    tags: tags
    vnetAddressSpace:  vnetHubAddressSpace
  }
}

module bastionSvc '../../shared/bicep/network/bastion.bicep' = {
  name: 'bastionSvc-Deployment'
  params: {
    location: location
    name: resourceNames.bastionService
    vnetId: vnetHub.outputs.vnetId
    tags: tags
    sku: 'Standard'
  }
}

module laws '../../shared/bicep/log-analytics-ws.bicep' = {
  name: 'laws-Deployment'
  params: {
    location: location
    name: resourceNames.laws

    tags: tags
  }
}


@description('The Azure Firewall deployment. This would normally be already provisioned by your platform team.')
module azfw './modules/firewall-basic.module.bicep' = {
  name: take('afw-${deployment().name}', 64)
  params: {
    location: location
    tags: tags
    afwVNetName: vnetHub.outputs.vnetName
    logAnalyticsWorkspaceId: laws.outputs.logAnalyticsWsId
    firewallName: resourceNames.azFw
    vnetSpokeAddressSpace: vnetSpokeAddressSpace
    subnetSpokeDevOpsAddressSpace: subnetSpokeDevOpsAddressSpace
    vnetHubAddressSpace: vnetHubAddressSpace
  }
}


@description('Resource name of the hub vnet')
output vnetHubName string = vnetHub.outputs.vnetName

@description('Resource Id of the hub vnet')
output vnetHubId string = vnetHub.outputs.vnetId

@description('The private IP of the Azure firewall.')
output firewallPrivateIp string = azfw.outputs.afwPrivateIp
