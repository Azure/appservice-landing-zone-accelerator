@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param name string

@description('Optional. Location for all resources.')
param location string

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('Array of access policy configurations, schema ref: https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults/accesspolicies?tabs=json#microsoftkeyvaultvaultsaccesspolicies-object')
param accessPolicies array = []

@description('Optional. Array of custom objects describing vNet links of the DNS zone. Each object should contain vnetName, vnetId, registrationEnabled')
param virtualNetworkLinks array = []

@description('Default is empty. If empty no Private endpoint will be created fro the resoure. Otherwise, the subnet where the private endpoint will be attached to')
param subnetPrivateEnpointId string = ''

// /subscriptions/f446c3cb-cee2-43df-a12c-2c858a062fdd/resourceGroups/rg-hub-appSvc-LZA-dev-northeurope/providers/Microsoft.Network/virtualNetworks/vnet-appsvc-lza-dev-neu-hub",
@description('if empty, private dns zone will be deployed in the current RG scope')
param vnetHubResourceId string

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')

var keyvaultDnsZoneName = 'privatelink.vaultcore.azure.net'

module keyvault '../../../shared/bicep/keyvault.bicep' = {
  name: 'keyvaultDeployment'
  params: {
    name: name
    location: location
    tags: tags
    hasPrivateEndpoint: !empty(subnetPrivateEnpointId) // hasPrivateEnpoint
    accessPolicies: accessPolicies
  }
}

module keyvaultPrivateDnsZone '../../../shared/bicep/private-dns-zone.bicep' = if ( !empty(subnetPrivateEnpointId) ) {
  // condiotional scope is not working: https://github.com/Azure/bicep/issues/7367
  //scope: empty(vnetHubResourceId) ? resourceGroup() : resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4]) 
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: 'keyvaultPrivateDnsZoneDeployment'
  params: {
    name: keyvaultDnsZoneName
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module peKeyvault '../../../shared/bicep/private-endpoint.bicep' = if ( !empty(subnetPrivateEnpointId) ) {
  name: 'peKeyvaultDeployment'
  params: {
    name: 'pe-${keyvault.outputs.keyvaultName}'
    location: location
    tags: tags
    privateDnsZonesId: keyvaultPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: keyvault.outputs.keyvaultId
    snetId: subnetPrivateEnpointId
    subresource: 'vault'
  }
}

output vnetHubResourceId string = vnetHubResourceId
output tokens array = vnetHubSplitTokens
//output scopeRG string = resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4]).id
