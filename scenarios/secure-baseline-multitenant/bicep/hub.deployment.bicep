targetScope = 'resourceGroup'

// reference to the BICEP naming module
param naming object

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

@description('CIDR of the HUB vnet i.e. 192.168.0.0/24')
param hubVnetAddressSpace string

param tags object

var privateDnsZoneNames = {
  appConfiguration: 'privatelink.azconfig.io'
  webApps: 'privaprivatelink.azurewebsites.net'
  sqlDb: 'privatelink.${environment().suffixes.sqlServerHostname}'
  redis: 'privatelink.redis.cache.windows.net'
  keyvault: 'privatelink.vaultcore.azure.net'
}

var resourceNames = {
  bastionService: naming.bastionHost.name
  laws: '${naming.logAnalyticsWorkspace.name}-hub'
  azFw: naming.firewall.name
  vnetHub: '${naming.virtualNetwork.name}-hub'
}

var subnetInfo = loadJsonContent('./hub-vnet-snet-config.jsonc')

var hubVnetSubnets = [for item in subnetInfo.subnets: {
  name: item.name
  properties: {
    addressPrefix: item.addressPrefix
    privateEndpointNetworkPolicies: item.privateEndpointNetworkPolicies =~ 'Disabled' ? 'Disabled' : 'Enabled'
  }
}]

var virtualNetworkLinks = [
  {
    vnetName: vnetHub.outputs.vnetName
    vnetId: vnetHub.outputs.vnetId
    registrationEnabled: false
  }
]

module vnetHub '../../shared/bicep/vnet.bicep' = {
  name: 'vnetHubDeployment'
  params: {
    location: location
    name: resourceNames.vnetHub
    subnetsInfo: hubVnetSubnets
    tags: tags
    vnetAddressSpace:  hubVnetAddressSpace
  }
}

module bastionSvc '../../shared/bicep/bastion.bicep' = {
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

module azFw '../../shared/bicep/firewall.bicep' = {
  name: 'azFWDeployment'
  params: {
    location: location
    name: resourceNames.azFw    
    vnetId: vnetHub.outputs.vnetId
    tags: tags
  }
}

module privateDnsZoneAppConfig  '../../shared/bicep/private-dns-zone.bicep' = {
  name: 'privateDnsZoneAppConfigDeployment'
  params: {
    name: privateDnsZoneNames.appConfiguration
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module privateDnsKeyvault  '../../shared/bicep/private-dns-zone.bicep' = {
  name: 'privateDnsKeyvaultDeployment'
  params: {
    name: privateDnsZoneNames.keyvault
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module privateDnsRedis  '../../shared/bicep/private-dns-zone.bicep' = {
  name: 'privateDnsRedisDeployment'
  params: {
    name: privateDnsZoneNames.redis
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module privateDnsZoneSql  '../../shared/bicep/private-dns-zone.bicep' = {
  name: 'privateDnsZoneSqlDeployment'
  params: {
    name: privateDnsZoneNames.sqlDb
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module privateDnsWebApps  '../../shared/bicep/private-dns-zone.bicep' = {
  name: 'privateDnsWebAppsDeployment'
  params: {
    name: privateDnsZoneNames.webApps
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}
