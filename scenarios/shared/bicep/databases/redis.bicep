@description('Required. The name of the Redis cache resource. Start and end with alphanumeric. Consecutive hyphens not allowed')
@maxLength(63)
@minLength(1)
param name string

@description('Optional. The location to deploy the Redis cache service.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object = {}

@description('The name of an existing keyvault, that it will be used to store secrets (connection string)' )
param keyvaultName string

// @description('Optional. Enables system assigned managed identity on the resource.')
// param systemAssignedIdentity bool = false

// @description('Optional. The ID(s) to assign to the resource.')
// param userAssignedIdentities object = {}

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

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${name}-diagnosticSettings'

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

// var identityType = systemAssignedIdentity ? 'SystemAssigned' : !empty(userAssignedIdentities) ? 'UserAssigned' : 'None'

// var identity = {
//   type: identityType
//   userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
// }

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: keyvaultName
}

resource redisCache 'Microsoft.Cache/redis@2021-06-01' = {
  name: name
  location: location
  tags: tags
//  identity: identity    //20230301-getting a strange error that publcNetworkAccess and Identity cannot be set at the same time. The following updates can't be processed in one single request, please send seperate request to update them: 'properties.publicNetworkAccess,identity
  properties: {
    enableNonSslPort: enableNonSslPort
    minimumTlsVersion: '1.2'
    publicNetworkAccess: hasPrivateLink ? 'Disabled' : null
    redisConfiguration: !empty(redisConfiguration) ? redisConfiguration : null
    redisVersion: '6'
    replicasPerMaster: skuName == 'Premium' ? replicasPerMaster : null
    replicasPerPrimary: skuName == 'Premium' ? replicasPerPrimary : null
    shardCount: skuName == 'Premium' ? shardCount : null // Not supported in free tier
    sku: {
      capacity: capacity
      family: skuName == 'Premium' ? 'P' : 'C'
      name: skuName
    }
    subnetId: !empty(subnetId) ? subnetId : null
  }
  zones: skuName == 'Premium' ? pickZones('Microsoft.Cache', 'redis', location, 1) : null
}

resource redisConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2018-02-14' = {
  name: 'redisConStrSecret'
  parent: keyVault
  properties: {
    value: '${redisCache.properties.hostName},password=${redisCache.listKeys().primaryKey},ssl=True,abortConnect=False' //'${name}.redis.cache.windows.net,abortConnect=false,ssl=true,password=${listKeys(redis.id, redis.apiVersion).primaryKey}'
  }
} 

resource redisCache_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ( !empty(diagnosticWorkspaceId) ) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId:  null 
    workspaceId: empty(diagnosticWorkspaceId) ? null : diagnosticWorkspaceId
    eventHubAuthorizationRuleId: null 
    eventHubName:  null
    metrics: empty(diagnosticWorkspaceId) ? null : diagnosticsMetrics
    logs:  empty(diagnosticWorkspaceId) ? null : diagnosticsLogs
  }
  scope: redisCache
}

@description('The resource name.')
output name string = redisCache.name

@description('The resource ID.')
output resourceId string = redisCache.id

@description('The name of the resource group the Redis cache was created in.')
output resourceGroupName string = resourceGroup().name

@description('Redis hostname.')
output hostName string = redisCache.properties.hostName

@description('Redis SSL port.')
output sslPort int = redisCache.properties.sslPort

@description('The full resource ID of a subnet in a virtual network where the Redis cache was deployed in.')
output subnetId string = !empty(subnetId) ? redisCache.properties.subnetId : ''

@description('The location the resource was deployed into.')
output location string = redisCache.location

@description('The name of the secret in keyvault, holding the connection string to redis.')
output redisConnectionStringSecretName string = redisConnectionStringSecret.name
