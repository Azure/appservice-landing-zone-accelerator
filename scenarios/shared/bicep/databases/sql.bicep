@description('Required. The name of the Sql server.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Whether the resource has private links or not')
param hasPrivateLinks bool

@description('Conditional. The administrator username for the server. Required if no `administrators` object for AAD authentication is provided.')
param administratorLogin string = ''

@description('Conditional. The administrator login password. Required if no `administrators` object for AAD authentication is provided.')
@secure()
param administratorLoginPassword string = ''

@description('Conditional. The Azure Active Directory (AAD) administrator authentication. Required if no `administratorLogin` & `administratorLoginPassword` is provided.')
param administrators object = {}

@description('Conditional. The resource ID of a user assigned identity to be used by default. Required if "userAssignedIdentities" is not empty.')
param primaryUserAssignedIdentityId string = ''

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

// database related params
@description('Required. The name of the Sql database.')
param databaseName string

@description('Optional, default SQL_Latin1_General_CP1_CI_AS. The collation of the database.')
param databaseCollation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Optional, default is S0. The SKU of the database ')
@allowed([
  'S0'
  'S1'
  'S2'
  'S3'
  'S4'
  'S6'
  'S7'
  'S9'
  'S12'
])
param databaseSkuName string = 'S0'

@description('Whether to enable Transparent Data Encryption -defaults to \'true\'')
param enableTransparentDataEncryption bool = true

// @description('Optional. The Elastic Pools to create in the server.')
// param elasticPools array = []

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and neither firewall rules nor virtual network rules are set.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = ''

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  location: location
  name: name
  tags: tags
  identity: identity
  properties: {
    administratorLogin: !empty(administratorLogin) ? administratorLogin : null
    administratorLoginPassword: !empty(administratorLoginPassword) ? administratorLoginPassword : null
    administrators: !empty(administrators) ? {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: administrators.azureADOnlyAuthentication //false
      login: administrators.login
      principalType: administrators.principalType //Group
      sid: administrators.sid
      tenantId: administrators.tenantId
    } : null
    version: '12.0'
    minimalTlsVersion:  '1.2'
    primaryUserAssignedIdentityId: !empty(primaryUserAssignedIdentityId) ? primaryUserAssignedIdentityId : null
    publicNetworkAccess: !empty(publicNetworkAccess) ? any(publicNetworkAccess) : ( hasPrivateLinks ? 'Disabled' : null )
  }
}

resource database 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: tags
  sku: {
    name: databaseSkuName
  }
  properties: {
    collation: databaseCollation
  }
}

resource tde 'Microsoft.Sql/servers/databases/transparentDataEncryption@2021-02-01-preview' = {
  parent: database
  name: 'current'
  properties: {
    state: enableTransparentDataEncryption ? 'Enabled' : 'Disabled'
  }
}

@description('The name of the deployed SQL server.')
output sqlServerName string = sqlServer.name

@description('The resource ID of the deployed SQL server.')
output sqlServerId string = sqlServer.id

@description('The resource group of the deployed SQL server.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(sqlServer.identity, 'principalId') ? sqlServer.identity.principalId : ''

@description('The location the resource was deployed into.')
output location string = sqlServer.location
