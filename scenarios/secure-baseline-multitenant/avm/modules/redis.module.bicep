// ------------------
//    PARAMETERS
// ------------------

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

@description('Optional. Specifies whether the non-ssl Redis server port (6379) is enabled.')
param enableNonSslPort bool = false

@description('Optional. All Redis Settings. Few possible keys: rdb-backup-enabled,rdb-storage-connection-string,rdb-backup-frequency,maxmemory-delta,maxmemory-policy,notify-keyspace-events,maxmemory-samples,slowlog-log-slower-than,slowlog-max-len,list-max-ziplist-entries,list-max-ziplist-value,hash-max-ziplist-entries,hash-max-ziplist-value,set-max-intset-entries,zset-max-ziplist-entries,zset-max-ziplist-value etc.')
param redisConfiguration object = {}

@minValue(1)
@description('Optional. The number of replicas to be created per primary.')
param replicasPerMaster int = 1

@minValue(1)
@description('Optional. The number of replicas to be created per primary.')
param replicasPerPrimary int = 1

@minValue(1)
@description('Optional. The number of shards to be created on a Premium Cluster Cache.')
param shardCount int = 1

@allowed([
  0
  1
  2
  3
  4
  5
  6
])
@description('Optional. The size of the Redis cache to deploy. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4).')
param capacity int = 2

@allowed([
  'Basic'
  'Premium'
  'Standard'
])
@description('Optional, default is Standard. The type of Redis cache to deploy.')
param skuName string = 'Standard'

@description('Optional. The full resource ID of a subnet in a virtual network to deploy the Redis cache in. Example format: /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/Microsoft.{Network|ClassicNetwork}/VirtualNetworks/vnet1/subnets/subnet1.')
param subnetId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticWorkspaceId string = ''

@description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource.')
@allowed([
  'allLogs'
  'ConnectedClientList'
])
param diagnosticLogCategoriesToEnable array = [
  'allLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Has the resource private endpoint?')
param hasPrivateLink bool = false

// ------------------
//    VARIABLES
// ------------------

var diagnosticsLogsSpecified = [for category in filter(diagnosticLogCategoriesToEnable, item => item != 'allLogs'): {
  category: category
  enabled: true
}]

var diagnosticsLogs = contains(diagnosticLogCategoriesToEnable, 'allLogs') ? [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
] : diagnosticsLogsSpecified

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

// ------------------
//    RESOURCES
// ------------------

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: keyvaultName
}

module redisCache 'br/public:avm/res/cache/redis:0.3.2' = {
  name: '${name}-redis-deployment'
  params: {
    name: name
    location: location
    enableNonSslPort: enableNonSslPort
    minimumTlsVersion: '1.2'
    publicNetworkAccess: hasPrivateLink ? 'Disabled' : null
    redisConfiguration: !empty(redisConfiguration) ? redisConfiguration : null
    redisVersion: '6'
    replicasPerMaster: skuName == 'Premium' ? replicasPerMaster : null
    replicasPerPrimary: skuName == 'Premium' ? replicasPerPrimary : null
    shardCount: skuName == 'Premium' ? shardCount : null // Not supported in free tier
    skuName: skuName
    capacity: capacity
    subnetResourceId: !empty(subnetId) ? subnetId : null
    zoneRedundant: skuName == 'Premium' ? true : null
    zones: skuName == 'Premium' ? pickZones('Microsoft.Cache', 'redis', location, 1) : null
    diagnosticSettings: [
      {
        workspaceResourceId: empty(logAnalyticsWsId) ? null : logAnalyticsWsId
      }
      {
        eventHubAuthorizationRuleResourceId: null
      }
      { 
        eventHubName: null
      }
      {
        metricCategories: empty(diagnosticWorkspaceId) ? null : diagnosticsMetrics
      }
      {
        logCategoriesAndGroups: empty(diagnosticWorkspaceId) ? null : diagnosticsLogs
      }
    ]
    tags: tags
  }
}

resource redisCacheExisting 'Microsoft.Cache/redis@2023-08-01' existing = {
  name: redisCache.outputs.name
}

resource redisConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: 'redisConStrSecret'
  parent: keyVault
  properties: {
    value: '${name}.redis.cache.windows.net,abortConnect=false,ssl=true,password=${listKeys(redisCacheExisting.id, redisCacheExisting.apiVersion).primaryKey}' //'${name}.redis.cache.windows.net,abortConnect=false,ssl=true,password=${listKeys(redis.id, redis.apiVersion).primaryKey}'
  }
  dependsOn: [
    redisCacheExisting
  ]
} 

module redisPrivateDnsZone './private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
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
    name: take('pe-${redisCache.outputs.name}', 64)
    location: location
    tags: tags
    privateDnsZonesId: redisPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: redisCache.outputs.resourceId
    snetId: subnetPrivateEndpointId
    subresource: 'redisCache'
  }
}

// ------------------
//    OUTPUTS
// ------------------

@description('The resource name.')
output name string = redisCache.outputs.name

@description('The resource ID.')
output resourceId string = redisCache.outputs.resourceId

@description('The name of the resource group the Redis cache was created in.')
output resourceGroupName string = resourceGroup().name

@description('Redis hostname.')
output hostName string = redisCache.outputs.hostName

@description('Redis SSL port.')
output sslPort int = redisCache.outputs.sslPort

@description('The name of the secret in keyvault, holding the connection string to redis.')
output redisConnectionStringSecretName string = redisConnectionStringSecret.name
