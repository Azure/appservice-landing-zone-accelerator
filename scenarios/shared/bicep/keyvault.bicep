@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param name string

@description('Optional. Location for all resources.')
param location string

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object = {}

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

@description('Optional. Service endpoint object information. For security reasons, it is recommended to set the DefaultAction Deny.')
param networkAcls object = {}

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkAcls are not set.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = ''

@description('Use RBAC for keyvault access - and not accesspolicy (https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli)')
param enableRbacAuthorization bool


@description('Array of access policy configurations, schema ref: https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults/accesspolicies?tabs=json#microsoftkeyvaultvaultsaccesspolicies-object')
param accessPolicies array = []

@description('If the keyvault has private endpoints enabled.')
param hasPrivateEndpoint bool

var keyvaultNameLength = 24
var keyvaultNameValid = replace( replace( name, '_', '-'), '.', '-')
var keyvaultName = length(keyvaultNameValid) > keyvaultNameLength ? substring(keyvaultNameValid, 0, keyvaultNameLength) : keyvaultNameValid

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyvaultName
  location: location  
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: skuName
    }
    accessPolicies: accessPolicies
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection ? true : null  //It seems that you cannot set it to False even the first time. workaround is not to set it at all: https://github.com/Azure/bicep/issues/5223
    networkAcls: !empty(networkAcls) ? {
      bypass: contains(networkAcls, 'bypass') ? networkAcls.bypass : null
      defaultAction: contains(networkAcls, 'defaultAction') ? networkAcls.defaultAction : null
      virtualNetworkRules: contains(networkAcls, 'virtualNetworkRules') ? networkAcls.virtualNetworkRules : []
      ipRules: contains(networkAcls, 'ipRules') ? networkAcls.ipRules : []
    } : null
    publicNetworkAccess: !empty(publicNetworkAccess) ? any(publicNetworkAccess) : (hasPrivateEndpoint && empty(networkAcls) ? 'Disabled' : null)
    enableRbacAuthorization: enableRbacAuthorization
  }
}

output keyvaultId string = keyVault.id
output keyvaultName string = keyVault.name
