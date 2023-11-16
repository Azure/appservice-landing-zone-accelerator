@description('Required. The name of the DQL server resource. Lowercase letters, numbers, and hyphens. Cannot start or end with hyphen.')
@maxLength(63)
@minLength(1)
param name string

@description('Required. The name of the database. Cannot use: <>*%&:\\/? or control characters Cannot end with period or space')
@maxLength(128)
@minLength(1)
param databaseName string

@description('Optional. The location to deploy the Redis cache service.')
param location string 

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Conditional. The Azure Active Directory (AAD) administrator authentication. Required if no `sqlAdminLogin` & `sqlAdminPassword` is provided.')
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

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')
var sqlDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'

module sqlDbAndServer '../../../shared/bicep/databases/sql.bicep' = {
  name: 'sqlDbAndServer-${name}-Deployment'
  params: {
    name: name
    databaseName: databaseName
    location: location
    tags: tags
    hasPrivateLinks: !empty(subnetPrivateEndpointId)
    administrators: administrators
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
  }
}

module sqlServerPrivateDnsZone '../../../shared/bicep/private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
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
    name: take('pe-${sqlDbAndServer.outputs.sqlServerName}', 64)
    location: location
    tags: tags
    privateDnsZonesId: sqlServerPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: sqlDbAndServer.outputs.sqlServerId
    snetId: subnetPrivateEndpointId
    subresource: 'sqlServer'
  }
}

output sqlServerName string = sqlDbAndServer.outputs.sqlServerName
output sqlServerId string = sqlDbAndServer.outputs.sqlServerId
