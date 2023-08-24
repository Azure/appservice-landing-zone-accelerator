// ================ //
// Parameters       //
// ================ //
// General

@maxLength(60)
@description('Required. Name of the site.')
param name string

@description('Optional. Location for all Resources.')
param location string

@description('Required. Type of site to deploy.')
@allowed([
  'functionapp' // function app windows os
  'functionapp,linux' // function app linux os
  // 'functionapp,workflowapp' // logic app workflow
  // 'functionapp,workflowapp,linux' // logic app docker container
  'app' // normal web app
  'app,linux' // normal web app linux OS
  'app,linux,container' //web app for containers - linux
])
param kind string

@description('Required. The resource ID of the app service plan to use for the site.')
param serverFarmResourceId string

@description('Optional. Configures a site to accept only HTTPS requests. Issues redirect for HTTP requests.')
param httpsOnly bool = true

@description('Optional. If client affinity is enabled.')
param clientAffinityEnabled bool = true

@description('Optional. The resource ID of the app service environment to use for this resource.')
param appServiceEnvironmentId string = ''

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Optional. The resource ID of the assigned identity to be used to access a key vault with.')
param keyVaultAccessIdentityResourceId string = ''

@description('Optional. Checks if Customer provided storage account is required.')
param storageAccountRequired bool = false

@description('Optional. Azure Resource Manager ID of the Virtual network and subnet to be joined by Regional VNET Integration. This must be of the form /subscriptions/{subscriptionName}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}.')
param virtualNetworkSubnetId string = ''

@allowed(['windowsNet6', 'windowsNet7', 'windowsAspNet486', 'linuxJava17Se', 'linuxNet7', 'linuxNet6', 'linuxNode18'])
@description('Mandatory. Predefined set of config settings.')
param siteConfigSelection string 

@description('Optional. Required if app of kind functionapp. Resource ID of the storage account to manage triggers and logging function executions.')
param storageAccountId string = ''

@description('Optional. Resource ID of the app insight to leverage for this resource.')
param appInsightId string = ''

@description('Optional. For function apps. If true the app settings "AzureWebJobsDashboard" will be set. If false not. In case you use Application Insights it can make sense to not set it for performance reasons.')
param setAzureWebJobsDashboard bool = contains(kind, 'functionapp') ? true : false

@description('Optional. The app settings-value pairs except for AzureWebJobsStorage, AzureWebJobsDashboard, APPINSIGHTS_INSTRUMENTATIONKEY and APPLICATIONINSIGHTS_CONNECTION_STRING.')
param appSettingsKeyValuePairs object = {}

// List of slots
@description('Optional. Configuration for deployment slots for an app.')
param slots array = []

// Tags
@description('Optional. Tags of the resource.')
param tags object = {}

// Diagnostic Settings

@description('Optional. Resource ID of log analytics workspace.')
param diagnosticWorkspaceId string = ''


@description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource.')
@allowed([
  'allLogs'
  'AppServiceHTTPLogs'
  'AppServiceConsoleLogs'
  'AppServiceAppLogs'
  'AppServiceAuditLogs'
  'AppServiceIPSecAuditLogs'
  'AppServicePlatformLogs'
  'FunctionAppLogs'
])
param diagnosticLogCategoriesToEnable array = kind == 'functionapp' ? [
  'FunctionAppLogs'
] : [
  'AppServiceHTTPLogs'
  'AppServiceConsoleLogs'
  'AppServiceAppLogs'
  'AppServiceAuditLogs'
  'AppServiceIPSecAuditLogs'
  'AppServicePlatformLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${name}-diagnosticSettings'


@description('Optional. Size of the function container.')
param containerSize int = -1

@description('Optional. Unique identifier that verifies the custom domains assigned to the app. Customer will add this ID to a txt record for verification.')
param customDomainVerificationId string = ''

@description('Optional. Maximum allowed daily memory-time quota (applicable on dynamic apps only).')
param dailyMemoryTimeQuota int = -1

@description('Optional. Setting this value to false disables the app (takes the app offline).')
param enabled bool = true

@description('Optional. Hostname SSL states are used to manage the SSL bindings for app\'s hostnames.')
param hostNameSslStates array = []

@description('Optional, default is false. If true, then a private endpoint must be assigned to the web app')
param hasPrivateLink bool

@description('Optional. Site redundancy mode.')
@allowed([
  'ActiveActive'
  'Failover'
  'GeoRedundant'
  'Manual'
  'None'
])
param redundancyMode string = 'None'

// =========== //
// Variables   //
// =========== //
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

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

var webapp_dns_name = '.azurewebsites.net'

// ============ //
// Dependencies //
// ============ //

var siteConfigConfigurationMap  = {
  windowsNet6 : {    
    metadata :[
      {
        name:'CURRENT_STACK'
        value:'dotnet'
      }
    ]
    netFrameworkVersion: 'v6.0'
    use32BitWorkerProcess: false    
  }
  windowsNet7 : {
    metadata :[
      {
        name:'CURRENT_STACK'
        value:'dotnet'
      }
    ]
    netFrameworkVersion: 'v7.0'
    use32BitWorkerProcess: false    
  }
  windowsAspNet486 : {
    metadata :[
      {
        name:'CURRENT_STACK'
        value:'dotnet'
      }
    ]
    netFrameworkVersion: 'v4.0'
    use32BitWorkerProcess: false    
  }
  linuxJava17Se: {
    linuxFxVersion: 'JAVA|17-java17'
    use32BitWorkerProcess: false    
  }
  linuxNet7: {
    linuxFxVersion: 'DOTNETCORE|7.0'
    use32BitWorkerProcess: false    
  }
  linuxNet6: {
    linuxFxVersion: 'DOTNETCORE|6.0'
    use32BitWorkerProcess: false    
  }
  linuxNode18: {
    linuxFxVersion: 'NODE|18-lts'
    use32BitWorkerProcess: false    
  }
}

resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  kind: kind
  tags: tags
  identity: identity
  properties: {
    serverFarmId: serverFarmResourceId
    clientAffinityEnabled: clientAffinityEnabled
    httpsOnly: httpsOnly
    hostingEnvironmentProfile: !empty(appServiceEnvironmentId) ? {
      id: appServiceEnvironmentId
    } : null
    storageAccountRequired: storageAccountRequired
    keyVaultReferenceIdentity: !empty(keyVaultAccessIdentityResourceId) ? keyVaultAccessIdentityResourceId : null
    virtualNetworkSubnetId: !empty(virtualNetworkSubnetId) ? virtualNetworkSubnetId : any(null)
    vnetRouteAllEnabled: !empty(virtualNetworkSubnetId) ? true : false
    siteConfig: siteConfigConfigurationMap[siteConfigSelection]
    clientCertEnabled: false
    clientCertExclusionPaths: null
    clientCertMode: 'Optional'
    cloningInfo: null
    containerSize: containerSize != -1 ? containerSize : null
    customDomainVerificationId: !empty(customDomainVerificationId) ? customDomainVerificationId : null
    dailyMemoryTimeQuota: dailyMemoryTimeQuota != -1 ? dailyMemoryTimeQuota : null
    enabled: enabled
    hostNameSslStates: hostNameSslStates
    hyperV: false
    redundancyMode: redundancyMode

  }
}

resource webAppHostBinding 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = if (hasPrivateLink == true) {
  parent: app
  name: '${app.name}${webapp_dns_name}'
  properties: {
    siteName: app.name
    hostNameType: 'Verified'
  }
}

module app_appsettings 'web-app.appsettings.bicep' = { //if (!empty(appSettingsKeyValuePairs)) {
  name: 'Site-Config-AppSettings-${uniqueString(deployment().name, location)}'
  params: {
    appName: app.name
    kind: kind
    storageAccountId: storageAccountId
    appInsightId: appInsightId
    setAzureWebJobsDashboard: setAzureWebJobsDashboard
    appSettingsKeyValuePairs: appSettingsKeyValuePairs
  }
}

@batchSize(1)
module app_slots 'web-app.slots.bicep' = [for (slot, index) in slots: {
  name: 'Slot-${slot.name}-${uniqueString(deployment().name, location)}'
  params: {
    name: slot.name
    appName: app.name
    location: location
    kind: kind
    serverFarmResourceId: serverFarmResourceId
    httpsOnly: contains(slot, 'httpsOnly') ? slot.httpsOnly : httpsOnly
    appServiceEnvironmentId: !empty(appServiceEnvironmentId) ? appServiceEnvironmentId : ''
    clientAffinityEnabled: contains(slot, 'clientAffinityEnabled') ? slot.clientAffinityEnabled : clientAffinityEnabled
    systemAssignedIdentity: contains(slot, 'systemAssignedIdentity') ? slot.systemAssignedIdentity : systemAssignedIdentity
    userAssignedIdentities: contains(slot, 'userAssignedIdentities') ? slot.userAssignedIdentities : userAssignedIdentities
    keyVaultAccessIdentityResourceId: contains(slot, 'keyVaultAccessIdentityResourceId') ? slot.keyVaultAccessIdentityResourceId : keyVaultAccessIdentityResourceId
    storageAccountRequired: contains(slot, 'storageAccountRequired') ? slot.storageAccountRequired : storageAccountRequired
    virtualNetworkSubnetId: contains(slot, 'virtualNetworkSubnetId') ? slot.virtualNetworkSubnetId : virtualNetworkSubnetId
    siteConfig: contains(slot, 'siteConfig') ? slot.siteConfig : siteConfigConfigurationMap[siteConfigSelection]
    storageAccountId: contains(slot, 'storageAccountId') ? slot.storageAccountId : storageAccountId
    appInsightId: contains(slot, 'appInsightId') ? slot.appInsightId : appInsightId
    setAzureWebJobsDashboard: contains(slot, 'setAzureWebJobsDashboard') ? slot.setAzureWebJobsDashboard : setAzureWebJobsDashboard
    diagnosticWorkspaceId: diagnosticWorkspaceId
    diagnosticLogCategoriesToEnable: contains(slot, 'diagnosticLogCategoriesToEnable') ? slot.diagnosticLogCategoriesToEnable : diagnosticLogCategoriesToEnable
    diagnosticMetricsToEnable: contains(slot, 'diagnosticMetricsToEnable') ? slot.diagnosticMetricsToEnable : diagnosticMetricsToEnable
    appSettingsKeyValuePairs: contains(slot, 'appSettingsKeyValuePairs') ? slot.appSettingsKeyValuePairs : appSettingsKeyValuePairs
    tags: tags
    containerSize: contains(slot, 'containerSize') ? slot.containerSize : -1
    customDomainVerificationId: contains(slot, 'customDomainVerificationId') ? slot.customDomainVerificationId : ''
    dailyMemoryTimeQuota: contains(slot, 'dailyMemoryTimeQuota') ? slot.dailyMemoryTimeQuota : -1
    enabled: contains(slot, 'enabled') ? slot.enabled : true
    hostNameSslStates: contains(slot, 'hostNameSslStates') ? slot.hostNameSslStates : []
    publicNetworkAccess: contains(slot, 'publicNetworkAccess') ? slot.publicNetworkAccess : ''
    redundancyMode: contains(slot, 'redundancyMode') ? slot.redundancyMode : 'None'
    vnetContentShareEnabled: contains(slot, 'vnetContentShareEnabled') ? slot.vnetContentShareEnabled : false
    vnetImagePullEnabled: contains(slot, 'vnetImagePullEnabled') ? slot.vnetImagePullEnabled : false
    vnetRouteAllEnabled: contains(slot, 'vnetRouteAllEnabled') ? slot.vnetRouteAllEnabled : false
  }
}]


resource slot_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if ( !empty(diagnosticWorkspaceId)) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId:  null
    eventHubName: null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
  scope: app
}

// =========== //
// Outputs     //
// =========== //

@description('The name of the site.')
output name string = app.name

@description('The resource ID of the site.')
output resourceId string = app.id

@description('The azure location of the site.')
output location string = app.location

@description('The list of the slots (names).')
output slots array = [for (slot, index) in slots: app_slots[index].outputs.name]

@description('The list of the slot resource ids.')
output slotResourceIds array = [for (slot, index) in slots: app_slots[index].outputs.resourceId]

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(app.identity, 'principalId') ? app.identity.principalId : ''


@description('The principal ID of the system assigned identity of slots.')
output slotSystemAssignedPrincipalIds array = [for (slot, index) in slots: app_slots[index].outputs.systemAssignedPrincipalId]

@description('Default hostname of the app.')
output defaultHostname string = app.properties.defaultHostName
