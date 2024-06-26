// ------------------
//    PARAMETERS
// ------------------

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

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkAcls are not set.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = ''

@description('If the keyvault has private endpoints enabled.')
param hasPrivateEndpoint bool = false 

@description('Optional. Service endpoint object information. For security reasons, it is recommended to set the DefaultAction Deny.')
param networkAcls object = {}

@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('Optional. Switch to enable/disable Key Vault\'s soft delete feature.')
param enableSoftDelete bool = true

@description('Optional. softDelete data retention days. It accepts >=7 and <=90.')
param softDeleteRetentionInDays int = 90

@description('Optional default is false. Provide \'true\' to enable Key Vault\'s purge protection feature.')
param enablePurgeProtection bool = false

@description('Use RBAC for keyvault access - and not accesspolicy (https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli)')
param enableRbacAuthorization bool = true

@description('Array of access policy configurations, schema ref: https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults/accesspolicies?tabs=json#microsoftkeyvaultvaultsaccesspolicies-object')
param accessPolicies array = []

// ------------------
//    VARIABLES
// ------------------

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')

var keyvaultDnsZoneName = 'privatelink.vaultcore.azure.net'

var keyvaultNameLength = 24

var keyvaultNameValid = replace( replace( name, '_', '-'), '.', '-')

var keyvaultName = length(keyvaultNameValid) > keyvaultNameLength ? substring(keyvaultNameValid, 0, keyvaultNameLength) : keyvaultNameValid

// ------------------
//    RESOURCES
// ------------------

module keyVault 'br/public:avm/res/key-vault/vault:0.6.2' = {
  name: take('${keyvaultName}-keyvaultModule-Deployment', 64)
  params: {
    name: keyvaultName
    location: location
    sku: skuName
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection
    accessPolicies: accessPolicies
    networkAcls: !empty(networkAcls) ? {
      bypass: contains(networkAcls, 'bypass') ? networkAcls.bypass : null
      defaultAction: contains(networkAcls, 'defaultAction') ? networkAcls.defaultAction : null
      virtualNetworkRules: contains(networkAcls, 'virtualNetworkRules') ? networkAcls.virtualNetworkRules : []
      ipRules: contains(networkAcls, 'ipRules') ? networkAcls.ipRules : []
    } : null
    publicNetworkAccess: !empty(publicNetworkAccess) ? any(publicNetworkAccess) : (hasPrivateEndpoint && empty(networkAcls) ? 'Disabled' : null)
    enableRbacAuthorization: enableRbacAuthorization
    tags: tags
  }
}
module keyvaultPrivateDnsZone '../../../shared/bicep/avm/private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
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
    name: take('pe-${keyVault.outputs.name}', 64)
    location: location
    tags: tags
    privateDnsZonesId: keyvaultPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: keyVault.outputs.resourceId
    snetId: subnetPrivateEndpointId
    subresource: 'vault'
  }
}
//output scopeRG string = resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4]).id

output keyvaultId string = keyVault.outputs.resourceId
output keyvaultName string = keyVault.outputs.name
