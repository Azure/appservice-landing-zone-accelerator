targetScope = 'resourceGroup'

// reference to the BICEP naming module
param naming object

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

@description('CIDR of the HUB vnet i.e. 192.168.0.0/24')
param hubVnetAddressSpace string

param tags object

var resourceNames = {
  storageAccount: '${naming.storageAccount.nameUnique}hub'
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

module storageHub '../../shared/bicep/storage/storage.bicep' = {
  name: 'storageHubDeployment'
  params: {    
    location: location
    name: resourceNames.storageAccount
    tags: tags
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
