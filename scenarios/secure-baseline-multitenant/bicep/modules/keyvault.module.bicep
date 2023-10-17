@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param name string

@description('Optional. Location for all resources.')
param location string

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('Optional. Array of custom objects describing vNet links of the DNS zone. Each object should contain vnetName, vnetId, registrationEnabled')
param virtualNetworkLinks array = []

@description('Default is empty. If empty no Private endpoint will be created for the resoure. Otherwise, the subnet where the private endpoint will be attached to')
param subnetPrivateEndpointId string = ''

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
    hasPrivateEndpoint: !empty(subnetPrivateEndpointId) // hasPrivateEnpoint
    enableRbacAuthorization: true
  }
}

module keyvaultPrivateDnsZone '../../../shared/bicep/private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
    // conditional scope is not working: https://github.com/Azure/bicep/issues/7367 but workaround: https://github.com/Azure/bicep/issues/10419#issuecomment-1507708535
  //scope: empty(vnetHubResourceId) ? resourceGroup() : resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4]) 
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: 'keyvaultPrivateDnsZoneDeployment'
  params: {
    name: keyvaultDnsZoneName
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module peKeyvault '../../../shared/bicep/private-endpoint.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  name: 'peKeyvaultDeployment'
  params: {
    name: take('pe-${keyvault.outputs.keyvaultName}', 64)
    location: location
    tags: tags
    privateDnsZonesId: keyvaultPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: keyvault.outputs.keyvaultId
    snetId: subnetPrivateEndpointId
    subresource: 'vault'
  }
}
//output scopeRG string = resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4]).id

output keyvaultId string = keyvault.outputs.keyvaultId
output keyvaultName string = keyvault.outputs.keyvaultName
