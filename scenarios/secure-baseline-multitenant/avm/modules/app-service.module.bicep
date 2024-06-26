// ------------------
//    PARAMETERS
// ------------------

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

@allowed([
  'Free'
  'Standard'
])
@description('Optional. Pricing tier of App Configuration.')
param appConfigSku string = 'Standard'

@description('Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param appConfigPublicNetworkAccess string = ''

@description('Optional. The amount of time in days that the configuration store will be retained when it is soft deleted.')
@minValue(1)
@maxValue(7)
param softDeleteRetentionInDays int = 7

@description('Optional default is false. Property specifying whether protection against purge is enabled for this configuration store.')
param enablePurgeProtection bool = false

@allowed([
  'None'
  'CanNotDelete'
  'ReadOnly'
])
@description('Optional. Specify the type of lock.')
param lock string

// ------------------
//    VARIABLES
// ------------------

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')
var webAppDnsZoneName = 'privatelink.azurewebsites.net'
var appConfigurationDnsZoneName = 'privatelink.azconfig.io'
var slotName = 'staging'
var redisConnStr = !empty(redisConnectionStringSecretName) ? {redisConnectionStringSecret: '@Microsoft.KeyVault(VaultName=${keyvaultName};SecretName=${redisConnectionStringSecretName})'} : {}

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
  ASE_I1V2_AZ: {
    name: 'I1v2'
    tier: 'IsolatedV2'
    size: 'I1v2'
    family: 'Iv2'
    capacity: 3
  }
  ASE_I2V2_AZ: {
    name: 'I2v2'
    tier: 'IsolatedV2'
    size: 'I2v2'
    family: 'Iv2'
    capacity: 3
  }
  ASE_I3V2_AZ: {
    name: 'I3v2'
    tier: 'IsolatedV2'
    size: 'I3v2'
    family: 'Iv2'
    capacity: 3
  }
   ASE_I1V2: {
    name: 'I1v2'
    tier: 'IsolatedV2'
    size: 'I1v2'
    family: 'Iv2'
    capacity: 1
  }
  ASE_I2V2: {
    name: 'I2v2'
    tier: 'IsolatedV2'
    size: 'I2v2'
    family: 'Iv2'
    capacity: 1
  }
  ASE_I3V2: {
    name: 'I3v2'
    tier: 'IsolatedV2'
    size: 'I3v2'
    family: 'Iv2'
    capacity: 1
  }
}

// ------------------
//    RESOURCES
// ------------------

resource keyvault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: keyvaultName
}

module ase './ase.bicep' =  if (deployAseV3){
  name: take('${aseName}-ASEv3-Deployment', 64)
  params: {
    name: aseName
    location: location
    tags: tags
    diagnosticWorkspaceId: logAnalyticsWsId
    subnetResourceId: subnetIdForVnetInjection
    zoneRedundant: endsWith(sku, 'AZ') ? true : false
    lock: lock
    allowNewPrivateEndpointConnections: true  //we need to expose our web app through AFD Premium, and that needs to create a Private Link. Otherwise the error you get is: 
    // Private Link for App Service Environment Site is only allowed on ASEv3's that have allowedPrivateEndpointConnections specified to be true object is not present in the request body.
  }
}

module appInsights 'br/public:avm/res/insights/component:0.3.1' = {
  name: 'appInsights-Deployment'
  params: {
    name: 'appi-${webAppName}'
    location: location
    workspaceResourceId: logAnalyticsWsId
    tags: tags
  }
}

module asp 'br/public:avm/res/web/serverfarm:0.2.2' = {
  name: take('appSvcPlan-${appServicePlanName}-Deployment', 64)
  params: {
    name: appServicePlanName
    location: location
    skuName: sku
    skuCapacity: skuConfigurationMap[sku]
    kind: (webAppBaseOs =~ 'linux') ? 'Linux' : 'Windows'
    diagnosticSettings: [{
        name: 'customSetting'
        workspaceResourceId: logAnalyticsWsId
    }]
    appServiceEnvironmentId: deployAseV3 ? ase.outputs.resourceId : null
    tags: tags
  }
}

module webApp './web-app.bicep' = {
  name: take('${webAppName}-webApp-Deployment', 64)
  params: {
    kind: (webAppBaseOs =~ 'linux') ? 'app,linux' : 'app'
    name:  webAppName
    location: location
    serverFarmResourceId: asp.outputs.resourceId
    diagnosticWorkspaceId: logAnalyticsWsId   
    virtualNetworkSubnetId: subnetIdForVnetInjection
    appInsightId: appInsights.outputs.resourceId
    siteConfigSelection:  (webAppBaseOs =~ 'linux') ? 'linuxNet6' : 'windowsNet6'
    hasPrivateLink: !(deployAseV3)  ? (!empty (subnetPrivateEndpointId))    : false
    systemAssignedIdentity: false
    userAssignedIdentities:  {
      '${webAppUserAssignedManagedIdenity.outputs.resourceId}': {}
    }
    appSettingsKeyValuePairs: redisConnStr
    slots: [
      {
        name: slotName
      }
    ]
    privateEndpoints: [
      {
        name: take('pe-${webAppName}-Deployment', 64)
        privateDnsZoneResourceIds: [
          (!empty(subnetPrivateEndpointId) && !deployAseV3 ) ? webAppPrivateDnsZone.outputs.privateDnsZonesId : ''
        ]
        subnetResourceId: subnetPrivateEndpointId
        service: 'sites'
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
  }
  dependsOn: [
    webApp
  ]
}

module webAppUserAssignedManagedIdenity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.2' = {
  name: 'appSvcUserAssignedManagedIdenity-Deployment'
  params: {
    name: managedIdentityName
    location: location
    tags: tags
  }
}

module webAppPrivateDnsZone './private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) && !deployAseV3 ) {
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

module appConfigStore 'br/public:avm/res/app-configuration/configuration-store:0.2.1' = if (deployAppConfig) {
  name: take('${appConfigurationName}-app-configuration-Deployment', 64)
  params: {   
    name: appConfigurationName
    location: location
    sku: appConfigSku
    tags: tags 
    roleAssignments: [
      {
        principalId: webAppUserAssignedManagedIdenity.outputs.principalId
        roleDefinitionIdOrName: '516239f1-63e1-4d78-a4de-a74fb236a071'  //App Configuration Data Reader 
      }
    ]
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          azConfigPrivateDnsZone.outputs.privateDnsZonesId
        ]
        subnetResourceId: subnetPrivateEndpointId
        service: 'configurationStores'
      }
    ]
    enablePurgeProtection: appConfigSku == 'Free' ? false : enablePurgeProtection
    publicNetworkAccess: !empty(appConfigPublicNetworkAccess) ? any(appConfigPublicNetworkAccess) : ((!empty (subnetPrivateEndpointId) ) ? 'Disabled' : null)
    softDeleteRetentionInDays: appConfigSku == 'Free' ? 1 : softDeleteRetentionInDays
    disableLocalAuth: false  // Currenlty (20-Mar-2023) there is a limitation - you need to enable Access Keys to add keyValues from ARM: https://learn.microsoft.com/en-us/azure/azure-app-configuration/howto-disable-access-key-authentication?tabs=portal#arm-template-access
  }
}

module azConfigPrivateDnsZone './private-dns-zone.bicep' = if ( !empty(subnetPrivateEndpointId) && deployAppConfig ) {
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

module webAppIdentityOnKeyvaultSecretsUser '../../../shared/bicep/role-assignments/role-assignment.bicep' = {
  name: 'webAppSystemIdentityOnKeyvaultSecretsUser-Deployment'
  params: {
    name: 'ra-webAppSystemIdentityOnKeyvaultSecretsUser'
    principalId: webAppUserAssignedManagedIdenity.outputs.principalId
    resourceId: keyvault.id
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6'  //Key Vault Secrets User  
  }
}

// ------------------
//    OUTPUTS
// ------------------
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
