@minLength(5)
@maxLength(50)
@description('Required. Name of the Azure App Configuration. Alphanumerics, underscores, and hyphens')
param name string

@description('Optional. Location for all Resources.')
param location string 

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@allowed([
  'Free'
  'Standard'
])
@description('Optional. Pricing tier of App Configuration.')
param sku string = 'Standard'

@description('Optional, default is true. Disables all authentication methods other than AAD authentication.')
param disableLocalAuth bool = true

@description('Optional default is false. Property specifying whether protection against purge is enabled for this configuration store.')
param enablePurgeProtection bool = false

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = ''

@description('If the resourcw has private endpoints enabled.')
param hasPrivateEndpoint bool

@description('Optional. The amount of time in days that the configuration store will be retained when it is soft deleted.')
@minValue(1)
@maxValue(7)
param softDeleteRetentionInDays int = 7

// @description('Optional. All Key / Values to create.')
// param keyValues array = []


var identityType = systemAssignedIdentity ? 'SystemAssigned' : !empty(userAssignedIdentities) ? 'UserAssigned' : 'None'

var identity = {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
}

resource configurationStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  identity: identity
  properties: {
    disableLocalAuth: disableLocalAuth
    enablePurgeProtection: sku == 'Free' ? false : enablePurgeProtection
    publicNetworkAccess: !empty(publicNetworkAccess) ? any(publicNetworkAccess) : (hasPrivateEndpoint ? 'Disabled' : null)
    softDeleteRetentionInDays: sku == 'Free' ? 0 : softDeleteRetentionInDays
  }
}

@description('The name of the app configuration.')
output name string = configurationStore.name

@description('The resource ID of the app configuration.')
output resourceId string = configurationStore.id

@description('The resource group the app configuration store was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(configurationStore.identity, 'principalId') ? configurationStore.identity.principalId : ''

@description('The location the resource was deployed into.')
output location string = configurationStore.location
