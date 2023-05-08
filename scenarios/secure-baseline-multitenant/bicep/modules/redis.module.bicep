@description('Required. The name of the Redis cache resource. Start and end with alphanumeric. Consecutive hyphens not allowed')
@maxLength(63)
@minLength(1)
param name string

@description('Optional. The location to deploy the Redis cache service.')
param location string 

@description('Optional. Tags of the resource.')
param tags object = {}

@description('The name of an existing keyvault, that it will be used to store secrets (connection string)' )
param keyvaultName string

@description('An existing Log Analytics WS Id for creating app Insights, diagnostics etc.')
param logAnalyticsWsId string

@description('Default is empty. If empty no Private endpoint will be created fro the resoure. Otherwise, the subnet where the private endpoint will be attached to')
param subnetPrivateEndpointId string = ''

@description('if empty, private dns zone will be deployed in the current RG scope')
param vnetHubResourceId string

@description('Optional. Array of custom objects describing vNet links of the DNS zone. Each object should contain vnetName, vnetId, registrationEnabled')
param virtualNetworkLinks array = []

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')

var redisCacheDnsZoneName = 'privatelink.redis.cache.windows.net'

module redis '../../../shared/bicep/databases/redis.bicep' = {
  name: take('${name}-redis-deployment', 64)
  params: {
    name: name
    location: location
    tags: tags
    diagnosticWorkspaceId: logAnalyticsWsId
    hasPrivateLink: !empty(subnetPrivateEndpointId)
    keyvaultName: keyvaultName
  }
}


module redisPrivateDnsZone '../../../shared/bicep/private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  // condiotional scope is not working: https://github.com/Azure/bicep/issues/7367
  //scope: empty(vnetHubResourceId) ? resourceGroup() : resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4]) 
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: take('${replace(redisCacheDnsZoneName, '.', '-')}-PrivateDnsZoneDeployment', 64)
  params: {
    name: redisCacheDnsZoneName
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module peRedis '../../../shared/bicep/private-endpoint.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  name: take('pe-${name}-Deployment', 64)
  params: {
    name: take('pe-${redis.outputs.name}', 64)
    location: location
    tags: tags
    privateDnsZonesId: redisPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: redis.outputs.resourceId
    snetId: subnetPrivateEndpointId
    subresource: 'redisCache'
  }
}


@description('The resource name.')
output name string = redis.outputs.name

@description('The resource ID.')
output resourceId string = redis.outputs.resourceId

@description('The name of the resource group the Redis cache was created in.')
output resourceGroupName string = resourceGroup().name

@description('Redis hostname.')
output hostName string = redis.outputs.hostName

@description('Redis SSL port.')
output sslPort int = redis.outputs.sslPort

@description('The name of the secret in keyvault, holding the connection string to redis.')
output redisConnectionStringSecretName string = redis.outputs.redisConnectionStringSecretName
