// Parameters
@description('Required. Azure location to which the resources are to be deployed')
param location string

@description('Required. The naming module for facilitating resource naming convention.')
param naming object

@description('Optional. The Azure Cache for Redis Enterprise sku.')
@allowed([
  'EnterpriseFlash_F1500'
  'EnterpriseFlash_F300'
  'EnterpriseFlash_F700'
  'Enterprise_E10'
  'Enterprise_E100'
  'Enterprise_E20'
  'Enterprise_E50'
])
param skuName string = 'Enterprise_E10'

@description('Optional. The Azure Cache for Redis Enterprise capacity.')
@allowed([
  2
  4
  6
  8
])
param capacity int = 2

@description('Optional. The Azure Cache for Redis Enterprise clustering policy.')
@allowed([
  'EnterpriseCluster'
  'OSSCluster'
])
param clusteringPolicy string = 'EnterpriseCluster'

@description('Optional. The Azure Cache for Redis Enteprise eviction policy.')
@allowed([
  'AllKeysLFU'
  'AllKeysLRU'
  'AllKeysRandom'
  'NoEviction'
  'VolatileLFU'
  'VolatileLRU'
  'VolatileRandom'
  'VolatileTTL'
])
param evictionPolicy string = 'NoEviction'

@description('Optional. Persist data stored in Azure Cache for Redis Enterprise.')
@allowed([
   'Disabled'
   'RDB'
   'AOF'
])
param persistenceOption string = 'Disabled'

@description('Optional. The frequency at which data is written to disk.')
@allowed([
  '1s'
  'always'
])
param aofFrequency string = '1s'

@description('Optional. The frequency at which a snapshot of the database is created.')
@allowed([
  '12h'
  '1h'
  '6h'
])
param rdbFrequency string = '6h'

@description('Optional. The Azure Cache for Redis Enterprise module(s)')
@allowed([
  'RedisBloom'
  'RedisTimeSeries'
  'RedisJSON'
  'RediSearch'
])
param modulesEnabled array = []

@description('Required. The full id string identifying the spoke vnet (where Azure Cache for Redis Enteprise resides).')
param vnetId string

@description('Required. The full id string identifying the target subnet for Azure Cache for Redis Enterprise.')
param acrePrivateEndpointSubnetId string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('Required. Enable zone redundancy.')
param availabilityZoneOption bool = true

// Variables
var resourceNames = {
  acreName: naming.redisCache.name
  acreDbName: '${naming.redisCache.name}-db'
  acrePrivateEndpointName: '${naming.redisCache.name}-pe'
  acrePrivateEndpointNicName: naming.networkInterface.name
}

var rdbPersistence = persistenceOption == 'RDB' ? true : false
var aofPersistence = persistenceOption == 'AOF' ? true : false
var enableZoneRedundancy = availabilityZoneOption == true ? ['1','2','3'] : null

//Resources
resource acre 'Microsoft.Cache/redisEnterprise@2022-01-01' = {
  name: resourceNames.acreName
  location: location
  sku: {
    name: skuName
    capacity: capacity
  }
  properties: {
    minimumTlsVersion: '1.2'
  }
  zones: enableZoneRedundancy
  tags: tags
}

resource redisEnterpriseDb 'Microsoft.Cache/redisEnterprise/databases@2022-01-01' = {
  name: resourceNames.acreDbName
  parent: acre
  properties: {
    clientProtocol:'Encrypted'
    port: 10000
    clusteringPolicy: clusteringPolicy
    evictionPolicy: evictionPolicy
    persistence: {
      aofEnabled: aofPersistence
      aofFrequency: aofPersistence ? aofFrequency : null
      rdbEnabled: rdbPersistence
      rdbFrequency: rdbPersistence ? rdbFrequency : null
    }
    modules: [for module in modulesEnabled: {
      name: module
    }] 
  }
}

resource acrePrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: resourceNames.acrePrivateEndpointName
  location: location
  properties: {
    subnet: {
      id: acrePrivateEndpointSubnetId
    }
    customNetworkInterfaceName: resourceNames.acrePrivateEndpointNicName    
    privateLinkServiceConnections: [{
      name: resourceNames.acrePrivateEndpointName
      properties: {
        privateLinkServiceId: acre.id
        groupIds: ['redisEnterprise']
      }
    }]
  }
  tags: tags
}

module privateDnsZone 'modules/privateDnsZone.module.bicep' = {
  name: 'PrivateDnsZoneModule'
  params: {
    name: 'privatelink.redisenterprise.cache.azure.net'
    prefix: 'acre'
    vnetIds: [
      vnetId
    ]
    isAcreDnsZone: true
    registrationEnabled: false
    aRecords: []
    tags: tags
  }
}

//Output
output acreName string = acre.name
output acreId string = acre.id
output acrePrivateEndpointId string = acrePrivateEndpoint.id
output acrePrivateEndpointNicId string = acrePrivateEndpoint.properties.networkInterfaces[0].id
output acreHostName string = acre.properties.hostName
