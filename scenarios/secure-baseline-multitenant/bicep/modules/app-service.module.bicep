@description('Optional, default is false. Set to true if you want to deploy ASE v3 instead of Multitenant App Service Plan.')
param deployAseV3 bool = false


@description('Optional if deployAseV3 = false. The identifier for the App Service Environment v3 resource.')
@minLength(1)
@maxLength(36)
param aseName string

@description('Required. Name of the App Service Plan.')
@minLength(1)
@maxLength(40)
param appServicePlanName string

@description('Required. Name of the web app.')
@maxLength(60)
param webAppName string 

@description('Required. Name of the managed Identity that will be assigned to the web app.')
@minLength(3)
@maxLength(128)
param managedIdentityName string

@description('Required. Name of the Azure App Configuration. Alphanumerics, underscores, and hyphens. Must be unique')
@minLength(5)
@maxLength(50)
param appConfigurationName string

@description('Optional S1 is default. Defines the name, tier, size, family and capacity of the App Service Plan. Plans ending to _AZ, are deploying at least three instances in three Availability Zones. EP* is only for functions')
@allowed([ 'S1', 'S2', 'S3', 'P1V3', 'P2V3', 'P3V3', 'P1V3_AZ', 'P2V3_AZ', 'P3V3_AZ', 'EP1', 'EP2', 'EP3', 'ASE_I1V2_AZ', 'ASE_I2V2_AZ', 'ASE_I3V2_AZ', 'ASE_I1V2', 'ASE_I2V2', 'ASE_I3V2' ])
param sku string

@description('Optional. Location for all resources.')
param location string

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('Default is empty. If empty no Private Endpoint will be created for the resoure. Otherwise, the subnet where the private endpoint will be attached to')
param subnetPrivateEndpointId string = ''

@description('Optional. Array of custom objects describing vNet links of the DNS zone. Each object should contain vnetName, vnetId, registrationEnabled')
param virtualNetworkLinks array = []

@description('if empty, private dns zone will be deployed in the current RG scope')
param vnetHubResourceId string

@description('Kind of server OS of the App Service Plan')
@allowed([ 'Windows', 'Linux'])
param webAppBaseOs string

@description('An existing Log Analytics WS Id for creating app Insights, diagnostics etc.')
param logAnalyticsWsId string

@description('The subnet ID that is dedicated to Web Server, for Vnet Injection of the web app. If deployAseV3=true then this is the subnet dedicated to the ASE v3')
param subnetIdForVnetInjection string

@description('The name of an existing keyvault, that it will be used to store secrets (connection string)' )
param keyvaultName string

@description('The name of secret that stores the redis connection string' )
param redisConnectionStringSecretName string

@description('The connection string of the default SQL Database' )
param sqlDbConnectionString string

@description('Deploy an azure app configuration, or not')
param deployAppConfig bool

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')

var webAppDnsZoneName = 'privatelink.azurewebsites.net'
var appConfigurationDnsZoneName = 'privatelink.azconfig.io'
var slotName = 'staging'

var redisConnStr = !empty(redisConnectionStringSecretName) ? {redisConnectionStringSecret: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${redisConnectionStringSecretName})'} : {}
// var sqlConnStr = !empty(sqlDbConnectionString) ? { sqlDefaultDbConnectionString: sqlDbConnectionString } : {}

resource keyvault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: keyvaultName
}

module ase '../../../shared/bicep/app-services/ase/ase.bicep' = if (deployAseV3) {
  name: take('${aseName}-ASEv3-Deployment', 64)
  params: {
    name: aseName
    location: location
    tags: tags
    diagnosticWorkspaceId: logAnalyticsWsId
    subnetResourceId: subnetIdForVnetInjection
    zoneRedundant: endsWith(sku, 'AZ') ? true : false
    allowNewPrivateEndpointConnections: true  //we need to expose our web app through AFD Premium, and that needs to create a Private Link. Otherwise the error you get is: 
    // Private Link for App Service Environment Site is only allowed on ASEv3's that have allowedPrivateEndpointConnections specified to be true object is not present in the request body.
  }
}

// resource aseResource  'Microsoft.Web/hostingEnvironments@2022-09-01' existing = {
//   name: aseName
// }

// module asePrivateDnsZone '../../../shared/bicep/private-dns-zone.bicep' = if ( deployAseV3 ) {
//   // scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])   //let the Private DNS zone in the same spoke network as the ASE v3 - for testing
//   name: 'asev3-net-PrivateDnsZone-Deployment'
//   params: {
//     name: deployAseV3 ? '${aseResource.name}.appserviceenvironment.net' : ''
//     virtualNetworkLinks: virtualNetworkLinks
//     tags: tags
//     aRecords: [
//       {
//         name: '*'
//         ipv4Address: deployAseV3 ? reference('${aseResource.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0] : ''
//         ttl: 3600
//       }
//       {
//         name: '*.scm'
//         ipv4Address: deployAseV3 ? reference('${aseResource.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0] : ''
//         ttl: 3600
//       }
//       {
//         name: '@'
//         ipv4Address: deployAseV3 ? reference('${aseResource.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0] : ''
//         ttl: 3600
//       }
//     ]
//   }
//   dependsOn: [
//     ase
//   ]
// }

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
    hostingEnvironmentProfileId: deployAseV3 ? ase.outputs.resourceId : ''
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
    virtualNetworkSubnetId: !(deployAseV3)  ? subnetIdForVnetInjection  : ''                              // no
    appInsightId: appInsights.outputs.appInsResourceId
    siteConfigSelection:  (webAppBaseOs =~ 'linux') ? 'linuxNet6' : 'windowsNet6'
    hasPrivateLink: !(deployAseV3)  ? (!empty (subnetPrivateEndpointId))    : false                           // no
    systemAssignedIdentity: false
    userAssignedIdentities:  {
      '${webAppUserAssignedManagedIdenity.outputs.id}': {}
    }
    appSettingsKeyValuePairs: redisConnStr // union(redisConnStr, sqlConnStr)
    slots: [
      {
        name: slotName
      }
    ]
  }
}

resource webAppExisting 'Microsoft.Web/sites@2022-03-01' existing =  {
  name: webAppName
}

resource webappConnectionstring 'Microsoft.Web/sites/config@2019-08-01' = if ( !empty(sqlDbConnectionString) ) {
  parent: webAppExisting
  name: 'connectionstrings'
  properties: {
    sqlDbConnectionString: {
      value: sqlDbConnectionString
      type: 'SQLAzure'
    }
    // MS_NotificationHubConnectionString: {
    //   value: listkeys(resourceId('Microsoft.NotificationHubs/namespaces/notificationHubs/authorizationRules', notificationHubNamespace_var, notificationHubName, 'DefaultFullSharedAccessSignature'), '2017-04-01').primaryConnectionString
    //   type: 'Custom'
    // }
  }
  dependsOn: [
    webApp
  ]
}

module webAppUserAssignedManagedIdenity '../../../shared/bicep/managed-identity.bicep' = {
  name: 'appSvcUserAssignedManagedIdenity-Deployment'
  params: {
    name: managedIdentityName
    location: location
    tags: tags
  }
}

module webAppPrivateDnsZone '../../../shared/bicep/private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) && !deployAseV3 ) {
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

module peWebApp '../../../shared/bicep/private-endpoint.bicep' = if ( !empty(subnetPrivateEndpointId) && !deployAseV3) {
  name:  take('pe-${webAppName}-Deployment', 64)
  params: {
    name: take('pe-${webApp.outputs.name}', 64)
    location: location
    tags: tags
    privateDnsZonesId: ( !empty(subnetPrivateEndpointId) && !deployAseV3 ) ? webAppPrivateDnsZone.outputs.privateDnsZonesId : ''
    privateLinkServiceId: webApp.outputs.resourceId
    snetId: subnetPrivateEndpointId
    subresource: 'sites'
  }
}

module peWebAppSlot '../../../shared/bicep/private-endpoint.bicep' = if ( !empty(subnetPrivateEndpointId) && !deployAseV3) {
  name:  take('pe-${webAppName}-slot-${slotName}-Deployment', 64)
  params: {
    name: take('pe-${webAppName}-slot-${slotName}', 64)
    location: location
    tags: tags
    privateDnsZonesId: ( !empty(subnetPrivateEndpointId) && !deployAseV3 ) ? webAppPrivateDnsZone.outputs.privateDnsZonesId : ''
    privateLinkServiceId: webApp.outputs.resourceId
    snetId: subnetPrivateEndpointId
    subresource: 'sites-${slotName}'
  }
}


module appConfigStore '../../../shared/bicep/app-configuration.bicep' = if (deployAppConfig) {
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

module azConfigPrivateDnsZone '../../../shared/bicep/private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) && deployAppConfig ) {
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
module peAzConfig '../../../shared/bicep/private-endpoint.bicep' = if ( !empty(subnetPrivateEndpointId)  && deployAppConfig) {
  name: take('pe-${appConfigurationName}-Deployment', 64)
  params: {
    name: ( !empty(subnetPrivateEndpointId)  && deployAppConfig) ? 'pe-${appConfigStore.outputs.name}' : ''
    location: location
    tags: tags
    privateDnsZonesId:  ( !empty(subnetPrivateEndpointId)  && deployAppConfig) ? azConfigPrivateDnsZone.outputs.privateDnsZonesId : ''
    privateLinkServiceId: ( !empty(subnetPrivateEndpointId)  && deployAppConfig) ? appConfigStore.outputs.resourceId : ''
    snetId: subnetPrivateEndpointId
    subresource: 'configurationStores'
  }
}


module webAppIdentityOnAppConfigDataReader '../../../shared/bicep/role-assignments/role-assignment.bicep' = if ( deployAppConfig ) {
  name: 'webAppSystemIdentityOnAppConfigDataReader-Deployment'
  params: {
    name: 'ra-webAppSystemIdentityOnAppConfigDataReader'
    principalId: webAppUserAssignedManagedIdenity.outputs.principalId
    resourceId: ( deployAppConfig ) ?  appConfigStore.outputs.resourceId : ''
    roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071'  //App Configuration Data Reader 
  }
}

module webAppIdentityOnKeyvaultSecretsUser '../../../shared/bicep/role-assignments/role-assignment.bicep' = {
  name: 'webAppSystemIdentityOnKeyvaultSecretsUser-Deployment'
  params: {
    name: 'ra-webAppSystemIdentityOnKeyvaultSecretsUser'
    principalId: webAppUserAssignedManagedIdenity.outputs.principalId
    resourceId: keyvault.id
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'  //Key Vault Secrets User  
  }
}

module webAppStagingSlotSystemIdentityOnAppConfigDataReader '../../../shared/bicep/role-assignments/role-assignment.bicep' = if ( deployAppConfig ) {
  name: 'webAppStagingSlotSystemIdentityOnAppConfigDataReader-Deployment'
  params: {
    name: 'ra-webAppStagingSlotSystemIdentityOnAppConfigDataReader'
    principalId: webAppUserAssignedManagedIdenity.outputs.principalId //webApp.outputs.slotSystemAssignedPrincipalIds[0]
    resourceId: ( deployAppConfig ) ?  appConfigStore.outputs.resourceId : ''
    roleDefinitionId: '516239f1-63e1-4d78-a4de-a74fb236a071'  //App Configuration Data Reader 
  }
}

module webAppStagingSlotSystemIdentityOnKeyvaultSecretsUser '../../../shared/bicep/role-assignments/role-assignment.bicep' = {
  name: 'webAppStagingSlotSystemIdentityOnKeyvaultSecretsUser-Deployment'
  params: {
    name: 'ra-webAppStagingSlotSystemIdentityOnKeyvaultSecretsUser'
    principalId: webAppUserAssignedManagedIdenity.outputs.principalId // webApp.outputs.slotSystemAssignedPrincipalIds[0]
    resourceId: keyvault.id
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'  //Key Vault Secrets User   
  }
}


output appConfigStoreName string =  deployAppConfig ? appConfigStore.outputs.name : ''
output appConfigStoreId string = deployAppConfig ? appConfigStore.outputs.resourceId : ''
output webAppName string = webApp.outputs.name
output webAppHostName string = webApp.outputs.defaultHostname
output webAppResourceId string = webApp.outputs.resourceId
output webAppLocation string = webApp.outputs.location
output webAppSystemAssignedPrincipalId string = webApp.outputs.systemAssignedPrincipalId

@description('The Internal ingress IP of the ASE.')
output internalInboundIpAddress string = (deployAseV3) ? ase.outputs.internalInboundIpAddress : ''

@description('The name of the ASE.')
output aseName string = (deployAseV3) ? ase.outputs.name : ''
