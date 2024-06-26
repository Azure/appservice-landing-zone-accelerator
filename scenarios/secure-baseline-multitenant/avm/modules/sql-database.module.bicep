// ------------------
//    PARAMETERS
// ------------------

@description('Required. The name of the DQL server resource. Lowercase letters, numbers, and hyphens. Cannot start or end with hyphen.')
@maxLength(63)
@minLength(1)
param name string

@description('Required. The name of the database. Cannot use: <>*%&:\\/? or control characters Cannot end with period or space')
@maxLength(128)
@minLength(1)
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

@description('Optional. The location to deploy the Redis cache service.')
param location string 

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Conditional. The Microsoft Entra ID administrator authentication. Required if no `sqlAdminLogin` & `sqlAdminPassword` is provided.')
param administrators object = {}

@description('Conditional. If sqlServerAdministrators is given, this is not required')
param sqlAdminLogin string = ''

@description('Conditional. If sqlServerAdministrators is given, this is not required')
@secure()
param sqlAdminPassword string = ''

@description('Optional. Array of custom objects describing vNet links of the DNS zone. Each object should contain vnetName, vnetId, registrationEnabled')
param virtualNetworkLinks array = []

@description('Default is empty. If empty no Private endpoint will be created for the resoure. Otherwise, the subnet where the private endpoint will be attached to')
param subnetPrivateEndpointId string = ''

@description('if empty, private dns zone will be deployed in the current RG scope')
param vnetHubResourceId string

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and neither firewall rules nor virtual network rules are set.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = ''

@description('Conditional. The resource ID of a user assigned identity to be used by default. Required if "userAssignedIdentities" is not empty.')
param primaryUserAssignedIdentityId string = ''

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

// ------------------
//    PARAMETERS
// ------------------

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')
var sqlDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

// ------------------
//    RESOURCES
// ------------------

module sqlDbAndServer 'br/public:avm/res/sql/server:0.4.1' = {
  name: 'sqlDbAndServer-${name}-Deployment'
  params: {
    name: name
    managedIdentities: identity
    databases: [
      {
        name: databaseName
        skuName: databaseSkuName
        collation: databaseCollation
        transparentDataEncryption: true
      }
    ]
    location: location
    minimalTlsVersion: '1.2'
    primaryUserAssignedIdentityId: !empty(primaryUserAssignedIdentityId) ? primaryUserAssignedIdentityId : null
    tags: tags
    publicNetworkAccess: !empty(publicNetworkAccess) ? any(publicNetworkAccess) : ( !empty(subnetPrivateEndpointId) ? 'Disabled' : null )
    administrators: !empty(administrators) ? {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: administrators.azureADOnlyAuthentication //false
      login: administrators.login
      principalType: administrators.principalType //Group
      sid: administrators.sid
      tenantId: administrators.tenantId
    } : null
    administratorLogin: !empty(sqlAdminLogin) ? sqlAdminLogin : null
    administratorLoginPassword: !empty(sqlAdminPassword) ? sqlAdminPassword : null
  }
}

module sqlServerPrivateDnsZone './private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  // conditional scope is not working: https://github.com/Azure/bicep/issues/7367
  //scope: empty(vnetHubResourceId) ? resourceGroup() : resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4]) 
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: take('${replace(sqlDnsZoneName, '.', '-')}-PrivateDnsZoneDeployment', 64)
  params: {
    name: sqlDnsZoneName
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module peSqlServer '../../../shared/bicep/private-endpoint.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  name: take('pe-${name}-Deployment', 64)
  params: {
    name: take('pe-${sqlDbAndServer.outputs.name}', 64)
    location: location
    tags: tags
    privateDnsZonesId: sqlServerPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: sqlDbAndServer.outputs.resourceId
    snetId: subnetPrivateEndpointId
    subresource: 'sqlServer'
  }
}

// ------------------
//    OUTPUTS
// ------------------

output sqlServerName string = sqlDbAndServer.outputs.name
