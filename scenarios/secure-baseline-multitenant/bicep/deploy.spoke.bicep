targetScope = 'resourceGroup'

// reference to the BICEP naming module
param naming object

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

@description('Optional, default is false. Set to true if you want to deploy ASE v3 instead of Multitenant App Service Plan.')
param deployAseV3 bool = false

@description('CIDR of the SPOKE vnet i.e. 192.168.0.0/24')
param vnetSpokeAddressSpace string

@description('CIDR of the subnet that will hold the app services plan')
param subnetSpokeAppSvcAddressSpace string

@description('CIDR of the subnet that will hold devOps agents etc ')
param subnetSpokeDevOpsAddressSpace string

@description('CIDR of the subnet that will hold the private endpoints of the supporting services')
param subnetSpokePrivateEndpointAddressSpace string

@description('Internal IP of the Azure firewall deployed in Hub. Used for creating UDR to route all vnet egress traffic through Firewall. If empty no UDR')
param firewallInternalIp string = ''

@description('if empty, private dns zone will be deployed in the current RG scope')
param vnetHubResourceId string = ''

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('Create (or not) a UDR for the App Service Subnet, to route all egress traffic through Hub Azure Firewall')
param enableEgressLockdown bool

@description('Deploy (or not) a redis cache')
param deployRedis bool

@description('Deploy (or not) an Azure SQL with default database ')
param deployAzureSql bool

@description('Deploy (or not) an Azure app configuration')
param deployAppConfig bool

@description('Deploy (or not) an Azure virtual machine (to be used as jumphost)')
param deployJumpHost bool

// post deployment specific parameters for the jumpBox
@description('The URL of the Github repository to use for the Github Actions Runner. This parameter is optional. If not provided, the Github Actions Runner will not be installed. If this parameter is provided, then github_token must also be provided.')
param githubRepository string = '' 

@description('The token to use for the Github Actions Runner. This parameter is optional. If not provided, the Github Actions Runner will not be installed. If this parameter is provided, then github_repository must also be provided.')
param githubToken string = '' 

@description('The URL of the Azure DevOps organization to use for the Azure DevOps Agent. This parameter is optional. If not provided, the Github Azure DevOps will not be installed. If this parameter is provided, then ado_token must also be provided.')
param adoOrganization string = '' 

@description('The PAT token to use for the Azure DevOps Agent. This parameter is optional. If not provided, the Github Azure DevOps will not be installed. If this parameter is provided, then ado_organization must also be provided.')
param adoToken string = '' 

@description('A switch to indicate whether or not to install the Azure CLI, AZD CLI and git. This parameter is optional. If not provided, the Azure CLI, AZD CLI and git will not be installed')
param installClis bool = false

@description('A switch to indicate whether or not to install Sql Server Management Studio (SSMS). This parameter is optional. If not provided, SSMS will not be installed.')
param installSsms bool = false

@description('Optional S1 is default. Defines the name, tier, size, family and capacity of the App Service Plan. Plans ending to _AZ, are deplying at least three instances in three Availability Zones. EP* is only for functions')
@allowed([ 'S1', 'S2', 'S3', 'P1V3', 'P2V3', 'P3V3', 'P1V3_AZ', 'P2V3_AZ', 'P3V3_AZ', 'EP1', 'EP2', 'EP3' ])
param webAppPlanSku string

@description('Kind of server OS of the App Service Plan')
@allowed([ 'Windows', 'Linux'])
param webAppBaseOs string

@description('optional, default value is azureuser')
param adminUsername string

@description('mandatory, the password of the admin user')
@secure()
param adminPassword string

@description('Conditional. The Azure Active Directory (AAD) administrator authentication. Required if no `sqlAdminLogin` & `sqlAdminPassword` is provided.')
param sqlServerAdministrators object = {}

@description('Conditional. If sqlServerAdministrators is given, this is not required')
param sqlAdminLogin string = ''

@description('Conditional. If sqlServerAdministrators is given, this is not required')
@secure()
param sqlAdminPassword string = ''

@description('set to true if you want to auto approve the Private Endpoint of the AFD')
param autoApproveAfdPrivateEndpoint bool = true

var resourceNames = {
  storageAccount: naming.storageAccount.nameUnique
  vnetSpoke: take('${naming.virtualNetwork.name}-spoke', 80)
  snetAppSvc: 'snet-appSvc-${naming.virtualNetwork.name}-spoke'
  snetDevOps: 'snet-devOps-${naming.virtualNetwork.name}-spoke'
  snetPe: 'snet-pe-${naming.virtualNetwork.name}-spoke'
  appSvcUserAssignedManagedIdentity: take('${naming.userAssignedManagedIdentity.name}-appSvc', 128)
  vmJumpHostUserAssignedManagedIdentity: take('${naming.userAssignedManagedIdentity.name}-vmJumpHost', 128)
  keyvault: naming.keyVault.nameUnique
  logAnalyticsWs: naming.logAnalyticsWorkspace.name
  appInsights: naming.applicationInsights.name
  aspName: naming.appServicePlan.name
  webApp: naming.appService.nameUnique
  vmWindowsJumpbox: take('${naming.windowsVirtualMachine.name}-win-jumpbox', 64)
  redisCache: naming.redisCache.nameUnique
  sqlServer: naming.mssqlServer.nameUnique
  sqlDb:'sample-db'
  appConfig: take ('${naming.appConfiguration.nameUnique}-${ take( uniqueString(resourceGroup().id, subscription().id), 6) }', 50)
  frontDoor: naming.frontDoor.name
  frontDoorEndPoint: 'webAppLza-${ take( uniqueString(resourceGroup().id, subscription().id), 6) }'  //globally unique
  frontDoorWaf: naming.frontDoorFirewallPolicy.name
  routeTable: naming.routeTable.name
  routeEgressLockdown: '${naming.route.name}-egress-lockdown'
  idAfdApprovePeAutoApprover: take('${naming.userAssignedManagedIdentity.name}-AfdApprovePe', 128)
}

var udrRoutes = [
                  {
                    name: 'defaultEgressLockdown'
                    properties: {
                      addressPrefix: '0.0.0.0/0'
                      nextHopIpAddress: firewallInternalIp 
                      nextHopType: 'VirtualAppliance'
                    }
                  }
                ]

var subnets = [ 
  {
    name: resourceNames.snetAppSvc
    properties: {
      addressPrefix: subnetSpokeAppSvcAddressSpace
      privateEndpointNetworkPolicies: 'Enabled'  
      delegations: [
        {
          name: 'delegation'
          properties: {
            serviceName: 'Microsoft.Web/serverfarms'
          }
        }
      ]
      // networkSecurityGroup: {
      //   id: nsgAca.outputs.nsgID
      // } 
      // routeTable: {
      //   id: !empty(firewallInternalIp) && (enableEgressLockdown) ? routeTableToFirewall.outputs.resourceId : ''
      // } 
      routeTable: !empty(firewallInternalIp) && (enableEgressLockdown) ? {
        id: routeTableToFirewall.outputs.resourceId 
      } : null
    } 
  }
  {
    name: resourceNames.snetDevOps
    properties: {
      addressPrefix: subnetSpokeDevOpsAddressSpace
      privateEndpointNetworkPolicies: 'Enabled'    
    }
  }
  {
    name: resourceNames.snetPe
    properties: {
      addressPrefix: subnetSpokePrivateEndpointAddressSpace
      privateEndpointNetworkPolicies: 'Disabled'    
    }
  }
]

var virtualNetworkLinks = [
  {
    vnetName: vnetSpoke.outputs.vnetName
    vnetId: vnetSpoke.outputs.vnetId
    registrationEnabled: false
  }
  {
    vnetName: vnetHub.name
    vnetId: vnetHub.id
    registrationEnabled: false
  }
]

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')

resource vnetHub  'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: vnetHubSplitTokens[8]
}

module vnetSpoke '../../shared/bicep/network/vnet.bicep' = {
  name: 'vnetSpoke-Deployment'
  params: {    
    name: resourceNames.vnetSpoke
    location: location
    tags: tags    
    vnetAddressSpace:  vnetSpokeAddressSpace
    subnetsInfo: subnets
  }
}


module routeTableToFirewall '../../shared/bicep/network/udr.bicep' = if (!empty(firewallInternalIp) &&  (enableEgressLockdown) ) {
  name: 'routeTableToFirewall-Deployment'
  params: {
    name: resourceNames.routeTable
    location: location
    tags: tags
    routes: udrRoutes
  }
}

resource snetAppSvc 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: '${vnetSpoke.outputs.vnetName}/${resourceNames.snetAppSvc}'
}

resource snetDevOps 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: '${vnetSpoke.outputs.vnetName}/${resourceNames.snetDevOps}'
}

resource snetPe 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: '${vnetSpoke.outputs.vnetName}/${resourceNames.snetPe}'
}

module logAnalyticsWs '../../shared/bicep/log-analytics-ws.bicep' = {
  name: 'logAnalyticsWs-Deployment'
  params: {
    name: resourceNames.logAnalyticsWs
    location: location
    tags: tags
  }
}

module keyvault 'modules/keyvault.module.bicep' = {
  name: take('${resourceNames.keyvault}-keyvaultModule-Deployment', 64)
  params: {
    name: resourceNames.keyvault
    location: location
    tags: tags   
    vnetHubResourceId: vnetHubResourceId    
    subnetPrivateEndpointId: snetPe.id
    virtualNetworkLinks: virtualNetworkLinks
  }
}

module webApp 'modules/app-service.module.bicep' = {
  name: 'webAppModule-Deployment'
  params: {
    appServicePlanName: resourceNames.aspName
    webAppName: resourceNames.webApp
    managedIdentityName: resourceNames.appSvcUserAssignedManagedIdentity
    location: location
    logAnalyticsWsId: logAnalyticsWs.outputs.logAnalyticsWsId
    subnetIdForVnetInjection: snetAppSvc.id
    tags: tags
    vnetHubResourceId: vnetHubResourceId
    webAppBaseOs: webAppBaseOs
    subnetPrivateEndpointId: snetPe.id
    virtualNetworkLinks: virtualNetworkLinks   
    appConfigurationName: resourceNames.appConfig
    sku: webAppPlanSku
    keyvaultName: keyvault.outputs.keyvaultName
    //docs for envintoment(): > https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-deployment#example-1
    sqlDbConnectionString: (deployAzureSql) ?  'Server=tcp:${sqlServerAndDefaultDb.outputs.sqlServerName}${environment().suffixes.sqlServerHostname};Authentication=Active Directory Default;Database=${resourceNames.sqlDb};' : ''
    redisConnectionStringSecretName: (deployRedis) ? redisCache.outputs.redisConnectionStringSecretName : ''
    deployAppConfig: deployAppConfig     
  }
}

module afd '../../shared/bicep/network/front-door.bicep' = {
  name: take ('AzureFrontDoor-${resourceNames.frontDoor}-deployment', 64)
  params: {
    afdName: resourceNames.frontDoor
    diagnosticWorkspaceId: logAnalyticsWs.outputs.logAnalyticsWsId
    endpointName: resourceNames.frontDoorEndPoint
    originGroupName: resourceNames.frontDoorEndPoint
    origins: [
      {
          name: webApp.outputs.webAppName  //1-50 Alphanumerics and hyphens
          hostname: webApp.outputs.webAppHostName
          enabledState: true
          privateLinkOrigin: {
            privateEndpointResourceId: webApp.outputs.webAppResourceId
            privateLinkResourceType: 'sites'
            privateEndpointLocation: webApp.outputs.webAppLocation
          }
      }
    ]
    skuName:'Premium_AzureFrontDoor'
    wafPolicyName: resourceNames.frontDoorWaf 
  }
}

module autoApproveAfdPe 'modules/approve-afd-pe.module.bicep' = if (autoApproveAfdPrivateEndpoint) {
  name: take ('autoApproveAfdPe-${resourceNames.frontDoor}-deployment', 64)
  params: { 
    location: location
    idAfdPeAutoApproverName: resourceNames.idAfdApprovePeAutoApprover
  }
  dependsOn: [
    afd
  ]
}


module vmWindowsModule 'modules/vmJumphost.module.bicep' = if (deployJumpHost) {
  name: 'vmWindowsModule-Deployment'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    location: location
    tags: tags
    vmJumpHostUserAssignedManagedIdentityName: resourceNames.vmJumpHostUserAssignedManagedIdentity
    vmWindowsJumpboxName: resourceNames.vmWindowsJumpbox
    keyvaultName: keyvault.outputs.keyvaultName
    appConfigStoreId: webApp.outputs.appConfigStoreId
    subnetDevOpsId: snetDevOps.id
    githubRepository: githubRepository
    githubToken: githubToken
    adoOrganization: adoOrganization
    adoToken: adoToken
    installClis: installClis
    installSsms: installSsms 
  }
}


module redisCache 'modules/redis.module.bicep' = if (deployRedis) {
  name: take('${resourceNames.redisCache}-redisModule-Deployment', 64)
  params: {
    name: resourceNames.redisCache
    location: location
    tags: tags
    logAnalyticsWsId: logAnalyticsWs.outputs.logAnalyticsWsId  
    vnetHubResourceId: vnetHubResourceId
    subnetPrivateEndpointId: snetPe.id
    virtualNetworkLinks: virtualNetworkLinks
    keyvaultName: keyvault.outputs.keyvaultName
  }
}

//TODO: conditional deployment of SQL
module sqlServerAndDefaultDb 'modules/sql-database.module.bicep' = if (deployAzureSql) {
  name: take('${resourceNames.sqlServer}-sqlServer-Deployment', 64)
  params: {
    name: resourceNames.sqlServer
    databaseName: resourceNames.sqlDb
    location: location
    tags: tags 
    vnetHubResourceId: vnetHubResourceId
    subnetPrivateEndpointId: snetPe.id
    virtualNetworkLinks: virtualNetworkLinks
    administrators: sqlServerAdministrators
    sqlAdminLogin: sqlAdminLogin
    sqlAdminPassword: sqlAdminPassword
  }
}


output vnetSpokeName string = vnetSpoke.outputs.vnetName
output vnetSpokeId string = vnetSpoke.outputs.vnetId
//output sampleAppIngress string = webApp.outputs.fqdn
