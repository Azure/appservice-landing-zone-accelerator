@description('Required. The name of the app service plan to deploy.')
@minLength(1)
@maxLength(40)
param name string

@description('Optional. Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional S1 is default. Defines the name, tier, size, family and capacity of the App Service Plan. Plans ending to _AZ, are deplying at least three instances in three Availability Zones. EP* is only for functions')
@allowed([ 'S1', 'S2', 'S3', 'P1V3', 'P2V3', 'P3V3', 'P1V3_AZ', 'P2V3_AZ', 'P3V3_AZ', 'EP1', 'EP2', 'EP3' ])
param sku string

@description('Optional, default is Windows. Kind of server OS.')
@allowed([
  'Windows'
  'Linux'
])
param serverOS string = 'Windows'

// @description('Optional. The Resource ID of the App Service Environment to use for the App Service Plan.')
// param appServiceEnvironmentId string = ''

// @description('Optional. Target worker tier assigned to the App Service plan.')
// param workerTierName string = ''

@description('Optional. If true, apps assigned to this App Service plan can be scaled independently. If false, apps assigned to this App Service plan will scale to all instances of the plan.')
param perSiteScaling bool = false

@description('Optional, dafualt is 20. Maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan.')
param maximumElasticWorkerCount int = 20

// @description('Optional, default is false. If true, then starts with minimum 3 instances')
// param zoneRedundant bool = false

@description('Optional. Scaling worker count.')
param targetWorkerCount int = 0

@description('Optional. The instance size of the hosting plan (small, medium, or large).')
@allowed([
  0
  1
  2
])
param targetWorkerSize int = 0

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${name}-diagnosticSettings'

@description('Optional. Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticWorkspaceId string = ''

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

// =========== //
// Variables   //
// =========== //

// If sku is Elastic Premium - used for EP Function hosting. Default is true
// param isElasticPremium bool = true
// 'Optional, default is false. If true, then starts with minimum 3 instances')
var zoneRedundant  = endsWith(sku, 'LZA') ? true : false
var isElasticPremium = startsWith(sku, 'EP') ? true : false
var aspKind = isElasticPremium ? 'elastic' : (serverOS == 'Windows' ? '' : 'linux')

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

// https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/patterns-configuration-set#example
var skuConfigurationMap = {
  EP1: {
    name: 'EP1'
    tier: 'ElasticPremium'
    size: 'EP1'
    family: 'EP'
    capacity: 1
  }
  EP2: {
    name: 'EP2'
    tier: 'ElasticPremium'
    size: 'EP2'
    family: 'EP'
    capacity: 1
  }
  EP3: {
    name: 'EP3'
    tier: 'ElasticPremium'
    size: 'EP3'
    family: 'EP'
    capacity: 1
  }
  B1: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  B2: {
    name: 'B2'
    tier: 'Basic'
    size: 'B2'
    family: 'B'
    capacity: 1
  }
  B3: {
    name: 'B3'
    tier: 'Basic'
    size: 'B3'
    family: 'B'
    capacity: 1
  }
  S1: {
    name: 'S1'
    tier: 'Standard'
    size: 'S1'
    family: 'S'
    capacity: 1
  }
  S2: {
    name: 'S2'
    tier: 'Standard'
    size: 'S2'
    family: 'S'
    capacity: 1
  }
  S3: {
    name: 'S3'
    tier: 'Standard'
    size: 'S3'
    family: 'S'
    capacity: 1
  }
  P1V3: {
    name: 'P1V3'
    tier: 'PremiumV2'
    size: 'P1V3'
    family: 'Pv3'
    capacity: 1
  }
  P1V3_AZ: {
    name: 'P1V3'
    tier: 'PremiumV2'
    size: 'P1V3'
    family: 'Pv3'
    capacity: 3
  }
  P2V3: {
    name: 'P2V3'
    tier: 'PremiumV2'
    size: 'P2V3'
    family: 'Pv3'
    capacity: 1
  }
  P2V3_AZ: {
    name: 'P2V3'
    tier: 'PremiumV2'
    size: 'P2V3'
    family: 'Pv3'
    capacity: 3
  }
  P3V3: {
    name: 'P3V3'
    tier: 'PremiumV2'
    size: 'P3V3'
    family: 'Pv3'
    capacity: 1
  }
  P3V3_AZ: {
    name: 'P3V3'
    tier: 'PremiumV2'
    size: 'P3V3'
    family: 'Pv3'
    capacity: 3
  }
}

// =========== //
// Deployments //
// =========== //

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  kind: aspKind
  location: location
  tags: tags
  sku: skuConfigurationMap[sku]
  properties: {
    perSiteScaling: perSiteScaling
    maximumElasticWorkerCount: (maximumElasticWorkerCount < 3 && zoneRedundant) ? 3 : maximumElasticWorkerCount
    reserved: serverOS == 'Linux'
    targetWorkerCount: (targetWorkerCount < 3 && zoneRedundant) ? 3 : targetWorkerCount
    targetWorkerSizeId: targetWorkerSize
    zoneRedundant: zoneRedundant
  }
}

resource appServicePlan_diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if ( !empty(diagnosticWorkspaceId) ) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId:  null
    eventHubName: null
    metrics: diagnosticsMetrics
    logs: []
  }
  scope: appServicePlan
}

// =========== //
// Outputs     //
// =========== //
@description('The resource group the app service plan was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The name of the app service plan.')
output name string = appServicePlan.name

@description('The resource ID of the app service plan.')
output resourceId string = appServicePlan.id

@description('The location the resource was deployed into.')
output location string = appServicePlan.location
