@description('Required. The name of the app service plan to deploy.')
@minLength(1)
@maxLength(40)
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object = {}

// EXAMPLE OF USE 
// Example of SKU for Elastic Plan (hosting functions)
// sku object = {
//     name: 'EP1'
//     tier: 'ElasticPremium'
//     size: 'EP1'
//     family: 'EP'
//     capacity: 1
// }
// Example of SKU for Premium Plan (hosting apps or non auto scaling functions)
// sku object = {
//     name: 'P1v2'
//     tier: 'PremiumV2'
//     size: 'P1v2'
//     family: 'Pv2'
//     capacity: 1
// }
// Example of SKU for Standard Plan (hosting apps or non auto scaling functions)
// sku object = {
//     name: 'S1'
//     tier: 'Standard'
//     size: 'S1'
//     family: 'S'
//     capacity: 1
// }
@description('Optional EP1 is default. Defines the name, tier, size, family and capacity of the App Service Plan.')
param sku object = {
        name: 'EP1'
        tier: 'ElasticPremium'
        size: 'EP1'
        family: 'EP'
        capacity: 1
    }

@description('Optional, default is Windows. Kind of server OS.')
@allowed([
  'Windows'
  'Linux'
])
param serverOS string = 'Windows'

@description('If sku is Elastic Premium - used for EP Function hosting. Default is true')
param isElasticPremium bool = true

// @description('Optional. The Resource ID of the App Service Environment to use for the App Service Plan.')
// param appServiceEnvironmentId string = ''

// @description('Optional. Target worker tier assigned to the App Service plan.')
// param workerTierName string = ''

@description('Optional. If true, apps assigned to this App Service plan can be scaled independently. If false, apps assigned to this App Service plan will scale to all instances of the plan.')
param perSiteScaling bool = false

@description('Optional, dafualt is 20. Maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan.')
param maximumElasticWorkerCount int = 20

@description('Optional, default is false. If true, then starts with minimum 3 instances')
param zoneRedundant bool = false

@description('Optional. Scaling worker count.')
param targetWorkerCount int = 0

@description('Optional. The instance size of the hosting plan (small, medium, or large).')
@allowed([
  0
  1
  2
])
param targetWorkerSize int = 0

// @description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
// param roleAssignments array = []

// @description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
// param enableDefaultTelemetry bool = true

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${name}-diagnosticSettings'

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticStorageAccountId string = ''

@description('Optional. Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
param diagnosticEventHubName string = ''

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

var aspKind = isElasticPremium ? 'elastic' : (serverOS == 'Windows' ? '' : 'linux')

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

// =========== //
// Deployments //
// =========== //



resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  kind: aspKind
  location: location
  tags: tags
  sku: sku
  properties: {
    perSiteScaling: perSiteScaling
    maximumElasticWorkerCount: maximumElasticWorkerCount
    reserved: serverOS == 'Linux'
    targetWorkerCount: targetWorkerCount
    targetWorkerSizeId: targetWorkerSize
    zoneRedundant: zoneRedundant
  }
}

resource appServicePlan_diagnosticSettings 'Microsoft.Insights/diagnosticsettings@2021-05-01-preview' = if ((!empty(diagnosticStorageAccountId)) || (!empty(diagnosticWorkspaceId)) || (!empty(diagnosticEventHubAuthorizationRuleId)) || (!empty(diagnosticEventHubName))) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
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
