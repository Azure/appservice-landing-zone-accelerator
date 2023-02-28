@description('Required. Name of the App Service Plan.')
param appServicePlanName string

@description('Required. Name of the web app.')
param webAppName string

@description('Optional S1 is default. Defines the name, tier, size, family and capacity of the App Service Plan. EP* is only for functions')
@allowed([ 'B1', 'B2', 'B3', 'S1', 'S2', 'S3', 'PV1', 'PV2', 'PV3', 'EP1', 'EP2', 'EP3' ])
param sku string = 'S1'

@description('Optional. Location for all resources.')
param location string

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('Default is empty. If empty no Private endpoint will be created fro the resoure. Otherwise, the subnet where the private endpoint will be attached to')
param subnetPrivateEndpointId string = ''

@description('Optional. Array of custom objects describing vNet links of the DNS zone. Each object should contain vnetName, vnetId, registrationEnabled')
param virtualNetworkLinks array = []

@description('if empty, private dns zone will be deployed in the current RG scope')
param vnetHubResourceId string

@description('Kind of server OS of the App Service Plan')
param webAppBaseOS string

@description('An existing Log Analytics WS Id for creating app Insights, diagnostics etc.')
param logAnalyticsWsId string

@description('The subnet ID that is dedicated to Web Server, for Vnet Injection of the web app')
param subnetIdForVnetInjection string

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')

var webAppDnsZoneName = 'privatelink.azurewebsites.net'

module appInsights '../../../shared/bicep/app-insights.bicep' = {
  name: 'appInsightsDeployment'
  params: {
    name: 'appi-${webAppName}'
    location: location
    tags: tags
    workspaceResourceId: logAnalyticsWsId
  }
}

module asp '../../../shared/bicep/app-services/app-service-plan.bicep' = {
  name: take('appSvcPlan-${appServicePlanName}-Deployment', 64)
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    sku: sku
    serverOS: (webAppBaseOS =~ 'linux') ? 'Linux' : 'Windows'
    diagnosticWorkspaceId: logAnalyticsWsId
  }
}

module webApp '../../../shared/bicep/app-services/web-app.bicep' = {
  name: 'test-webAppWinDeployment'
  params: {
    kind: 'app'
    name:  webAppName
    location: location
    serverFarmResourceId: asp.outputs.resourceId
    diagnosticWorkspaceId: logAnalyticsWsId   
    virtualNetworkSubnetId: subnetIdForVnetInjection
    appInsightId: appInsights.outputs.appInsResourceId
    siteConfigSelection:  (webAppBaseOS =~ 'linux') ? 'linuxNet6' : 'windowsNet6'
    hasPrivateLink: (!empty (subnetPrivateEndpointId))
    // TODO Idenity - assign to KeyVault as well
  }
}

module webAppPrivateDnsZone '../../../shared/bicep/private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  // conditional scope is not working: https://github.com/Azure/bicep/issues/7367
  //scope: empty(vnetHubResourceId) ? resourceGroup() : resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4]) 
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: 'webAppPrivateDnsZoneDeployment'
  params: {
    name: webAppDnsZoneName
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module peWebApp '../../../shared/bicep/private-endpoint.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  name: 'peWebAppDeployment'
  params: {
    name: 'pe-${webApp.outputs.name}'
    location: location
    tags: tags
    privateDnsZonesId: webAppPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: webApp.outputs.resourceId
    snetId: subnetPrivateEndpointId
    subresource: 'sites'
  }
}
