@description('Required. Name of the App Service Plan.')
param appServicePlanName string

@description('Required. Name of the web app.')
param webAppName string

@minLength(5)
@maxLength(50)
@description('Required. Name of the Azure App Configuration. Alphanumerics, underscores, and hyphens')
param appConfigurationName string

@description('Optional S1 is default. Defines the name, tier, size, family and capacity of the App Service Plan. Plans ending to _AZ, are deplying at least three instances in three Availability Zones. EP* is only for functions')
@allowed([ 'B1', 'B2', 'B3', 'S1', 'S2', 'S3', 'P1V3', 'P2V3', 'P3V3', 'P1V3_AZ', 'P2V3_AZ', 'P3V3_AZ', 'EP1', 'EP2', 'EP3' ])
param sku string

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
param webAppBaseOs string

@description('An existing Log Analytics WS Id for creating app Insights, diagnostics etc.')
param logAnalyticsWsId string

@description('The subnet ID that is dedicated to Web Server, for Vnet Injection of the web app')
param subnetIdForVnetInjection string

@description('The name of an existing keyvault, that it will be used to store secrets (connection string)' )
param keyvaultName string

@description('The name of secret that stores the redis connection string' )
param redisConnectionStringSecretName string

@description('The connection string of the default SQL Database' )
param sqlDbConnectionString string

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')

var webAppDnsZoneName = 'privatelink.azurewebsites.net'
var appConfigurationDnsZoneName = 'privatelink.azconfig.io'
var slotName = 'staging'

resource keyvault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: keyvaultName
}

module appInsights '../../../shared/bicep/app-insights.bicep' = {
  name: 'appInsights-Deployment'
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
    serverOS: (webAppBaseOs =~ 'linux') ? 'Linux' : 'Windows'
    diagnosticWorkspaceId: logAnalyticsWsId
  }
}

module webApp '../../../shared/bicep/app-services/web-app.bicep' = {
  name: take('${webAppName}-webApp-Deployment', 64)
  params: {
    kind: (webAppBaseOs =~ 'linux') ? 'app,linux' : 'app'
    name:  webAppName
    location: location
    serverFarmResourceId: asp.outputs.resourceId
    diagnosticWorkspaceId: logAnalyticsWsId   
    virtualNetworkSubnetId: subnetIdForVnetInjection
    appInsightId: appInsights.outputs.appInsResourceId
    siteConfigSelection:  (webAppBaseOs =~ 'linux') ? 'linuxNet6' : 'windowsNet6'
    hasPrivateLink: (!empty (subnetPrivateEndpointId))
    systemAssignedIdentity: true
    appSettingsKeyValuePairs: {
      redisConnectionStringSecret: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${redisConnectionStringSecretName})'
      sqlDefaultDbConnectionString: sqlDbConnectionString
    }
    slots: [
      {
        name: slotName
      }
    ]
  }
}

module webAppPrivateDnsZone '../../../shared/bicep/private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  // conditional scope is not working: https://github.com/Azure/bicep/issues/7367
  //scope: empty(vnetHubResourceId) ? resourceGroup() : resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4]) 
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: take('${replace(webAppDnsZoneName, '.', '-')}-PrivateDnsZoneDeployment', 64)
  params: {
    name: webAppDnsZoneName
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}

module peWebApp '../../../shared/bicep/private-endpoint.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  name:  take('pe-${webAppName}-Deployment', 64)
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

// resource webAppExisting 'Microsoft.Web/sites@2022-03-01' existing = {
//   name: webApp.outputs.name
// }

// resource webAppSlotExisting 'Microsoft.Web/sites/slots@2022-03-01' existing = {
//   parent: webAppExisting
//   name: slotName
// }

module peWebAppSlot '../../../shared/bicep/private-endpoint.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  name:  take('pe-${webAppName}-slot-${slotName}-Deployment', 64)
  params: {
    name: 'pe-${webAppName}-slot-${slotName}'
    location: location
    tags: tags
    privateDnsZonesId: webAppPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: webApp.outputs.resourceId
    snetId: subnetPrivateEndpointId
    subresource: 'sites-${slotName}'
  }
}

//TODO: Conditional Deployment? 
module appConfigStore '../../../shared/bicep/app-configuration.bicep' = {
  name: take('${appConfigurationName}-app-configuration-Deployment', 64)
  params: {   
    name: appConfigurationName
    location: location
    tags: tags 
    hasPrivateEndpoint: (!empty (subnetPrivateEndpointId) )
    disableLocalAuth: false  // Currenlty (20-Mar-2023) there is a limitation - you need to enable Access Keys to add keyValues from ARM: https://learn.microsoft.com/en-us/azure/azure-app-configuration/howto-disable-access-key-authentication?tabs=portal#arm-template-access
  }
}

// resource appConfigStoreExisting 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' existing =  {
//   name: appConfigurationName
// }

// // Currenlty (20-Mar-2023) there is a limitation - you need to enable Access Keys to add keyValues from ARM: https://learn.microsoft.com/en-us/azure/azure-app-configuration/howto-disable-access-key-authentication?tabs=portal#arm-template-access
// // needs disableLocalAuth: false, in Microsoft.AppConfiguration/configurationStores
// resource configurationStoreSqlConnectionString 'Microsoft.AppConfiguration/configurationStores/keyValues@2022-05-01' = {
//   parent: appConfigStoreExisting
//   name: 'sqlDefaultDbConnectionString'
//   properties: {
//      value: sqlDbConnectionString
//   }
//   dependsOn: [
//     appConfigStore
//   ]
// }

module azConfigPrivateDnsZone '../../../shared/bicep/private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  // conditional scope is not working: https://github.com/Azure/bicep/issues/7367
  //scope: empty(vnetHubResourceId) ? resourceGroup() : resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4]) 
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: take('${replace(appConfigurationDnsZoneName, '.', '-')}-PrivateDnsZoneDeployment', 64)
  params: {
    name: appConfigurationDnsZoneName
    virtualNetworkLinks: virtualNetworkLinks
    tags: tags
  }
}
module peAzConfig '../../../shared/bicep/private-endpoint.bicep' = if ( !empty(subnetPrivateEndpointId) ) {
  name: take('pe-${appConfigurationName}-Deployment', 64)
  params: {
    name: 'pe-${appConfigStore.outputs.name}'
    location: location
    tags: tags
    privateDnsZonesId: azConfigPrivateDnsZone.outputs.privateDnsZonesId
    privateLinkServiceId: appConfigStore.outputs.resourceId
    snetId: subnetPrivateEndpointId
    subresource: 'configurationStores'
  }
}


module webAppSystemIdenityOnAppConfigDataReader '../../../shared/bicep/role-assignments/role-assignment.bicep' = {
  name: 'webAppSystemIdenityOnAppConfigDataReader-Deployment'
  params: {
    principalId: webApp.outputs.systemAssignedPrincipalId
    resourceId: appConfigStore.outputs.resourceId
    roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071'  //App Configuration Data Reader 
  }
}

module webAppSystemIdenityOnKeyvaultSecretsUser '../../../shared/bicep/role-assignments/role-assignment.bicep' = {
  name: 'webAppSystemIdenityOnKeyvaultSecretsUser-Deployment'
  params: {
    principalId: webApp.outputs.systemAssignedPrincipalId
    resourceId: keyvault.id
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'  //Key Vault Secrets User  
  }
}

module webAppStagingSlotSystemIdenityOnAppConfigDataReader '../../../shared/bicep/role-assignments/role-assignment.bicep' = {
  name: 'webAppStagingSlotSystemIdenityOnAppConfigDataReader-Deployment'
  params: {
    principalId: webApp.outputs.slotSystemAssignedPrincipalIds[0]
    resourceId: appConfigStore.outputs.resourceId
    roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071'  //App Configuration Data Reader 
  }
}

module webAppStagingSlotSystemIdenityOnKeyvaultSecretsUser '../../../shared/bicep/role-assignments/role-assignment.bicep' = {
  name: 'webAppStagingSlotSystemIdenityOnKeyvaultSecretsUser-Deployment'
  params: {
    principalId: webApp.outputs.slotSystemAssignedPrincipalIds[0]
    resourceId: keyvault.id
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'  //Key Vault Secrets User   
  }
}


output appConfigStoreName string = appConfigStore.outputs.name
output appConfigStoreId string = appConfigStore.outputs.resourceId
output webAppName string = webApp.outputs.name
output webAppHostName string = webApp.outputs.defaultHostname
output webAppResourceId string = webApp.outputs.resourceId
output webAppLocation string = webApp.outputs.location
output webAppSystemAssignedPrincipalId string = webApp.outputs.systemAssignedPrincipalId
