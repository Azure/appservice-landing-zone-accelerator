targetScope = 'resourceGroup'

// reference to the BICEP naming module
param naming object

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('CIDR of the HUB vnet i.e. 192.168.0.0/24')
param hubVnetAddressSpace string

@description('CIDR of the subnet hosting the azure Firewall')
param subnetHubFirewallAddressSpace string

@description('CIDR of the subnet hosting the Bastion Service')
param subnetHubBastionddressSpace string



//look https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-deployment#example-1
// TODO: Check if this is required or if we go with module (inline) implementation
// var privateDnsZoneNames = {
//   appConfiguration: 'privatelink.azconfig.io'
//   webApps: 'privaprivatelink.azurewebsites.net'
//   sqlDb: 'privatelink${environment().suffixes.sqlServerHostname}'
//   redis: 'privatelink.redis.cache.windows.net'
//   keyvault: 'privatelink.vaultcore.azure.net'
// }

var resourceNames = {
  bastionService: naming.bastionHost.name
  laws: '${naming.logAnalyticsWorkspace.name}-hub'
  azFw: naming.firewall.name
  vnetHub: '${naming.virtualNetwork.name}-hub'
  subnetFirewall: 'AzureFirewallSubnet'
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
    name: resourceNames.subnetBastion
    properties: {
      addressPrefix: subnetHubBastionddressSpace
      privateEndpointNetworkPolicies: 'Disabled'    
    }
  }
]


module vnetHub '../../shared/bicep/network/vnet.bicep' = {
  name: 'vnetHubDeployment'
  params: {
    location: location
    name: resourceNames.vnetHub
    subnetsInfo: subnets
    tags: tags
    vnetAddressSpace:  hubVnetAddressSpace
  }
}

module bastionSvc '../../shared/bicep/network/bastion.bicep' = {
  name: 'bastionSvcDeployment'
  params: {
    location: location
    name: resourceNames.bastionService
    vnetId: vnetHub.outputs.vnetId
    tags: tags
  }
}

module laws '../../shared/bicep/log-analytics-ws.bicep' = {
  name: 'lawsDeployment'
  params: {
    location: location
    name: resourceNames.laws

    tags: tags
  }
}

module azFw '../../shared/bicep/network/firewall.bicep' = {
  name: 'azFWDeployment'
  params: {
    location: location
    name: resourceNames.azFw    
    vnetId: vnetHub.outputs.vnetId
    diagnosticWorkspaceId: laws.outputs.logAnalyticsWsId
    tags: tags
  }
}

// module privateDnsZoneAppConfig  '../../shared/bicep/private-dns-zone.bicep' = {
//   name: 'privateDnsZoneAppConfigDeployment'
//   params: {
//     name: privateDnsZoneNames.appConfiguration
//     virtualNetworkLinks: virtualNetworkLinks
//     tags: tags
//   }
// }

// module privateDnsKeyvault  '../../shared/bicep/private-dns-zone.bicep' = {
//   name: 'privateDnsKeyvaultDeployment'
//   params: {
//     name: privateDnsZoneNames.keyvault
//     virtualNetworkLinks: virtualNetworkLinks
//     tags: tags
//   }
// }

// module privateDnsRedis  '../../shared/bicep/private-dns-zone.bicep' = {
//   name: 'privateDnsRedisDeployment'
//   params: {
//     name: privateDnsZoneNames.redis
//     virtualNetworkLinks: virtualNetworkLinks
//     tags: tags
//   }
// }

// module privateDnsZoneSql  '../../shared/bicep/private-dns-zone.bicep' = {
//   name: 'privateDnsZoneSqlDeployment'
//   params: {
//     name: privateDnsZoneNames.sqlDb
//     virtualNetworkLinks: virtualNetworkLinks
//     tags: tags
//   }
// }

// module privateDnsWebApps  '../../shared/bicep/private-dns-zone.bicep' = {
//   name: 'privateDnsWebAppsDeployment'
//   params: {
//     name: privateDnsZoneNames.webApps
//     virtualNetworkLinks: virtualNetworkLinks
//     tags: tags
//   }
// }


output vnetHubName string = vnetHub.outputs.vnetName
output vnetHubId string = vnetHub.outputs.vnetId
