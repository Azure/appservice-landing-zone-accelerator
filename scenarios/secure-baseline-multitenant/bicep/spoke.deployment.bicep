targetScope = 'resourceGroup'

// reference to the BICEP naming module
param naming object

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

@description('CIDR of the SPOKE vnet i.e. 192.168.0.0/24')
param spokeVnetAddressSpace string

@description('CIDR of the subnet that will hold the app services plan')
param subnetSpokeAppSvcAddressSpace string

@description('CIDR of the subnet that will hold devOps agents etc ')
param subnetSpokeDevOpsAddressSpace string

@description('CIDR of the subnet that will hold the private endpoints of the supporting services')
param subnetSpokePrivateEndpointAddressSpace string

@description('if empty, private dns zone will be deployed in the current RG scope')
param vnetHubResourceId string = ''

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('Kind of server OS of the App Service Plan')
param webAppBaseOS string

@description('optional, default value is azureuser')
param adminUsername string

@description('mandatory, the password of the admin user')
@secure()
param adminPassword string

@description('Conditional. The Azure Active Directory (AAD) administrator authentication. Required if no `administratorLogin` & `administratorLoginPassword` is provided.')
param sqlServerAdministrators object = {}

var resourceNames = {
  storageAccount: naming.storageAccount.nameUnique
  vnetSpoke: '${naming.virtualNetwork.name}-spoke'
  snetAppSvc: 'snet-appSvc-${naming.virtualNetwork.name}-spoke'
  snetDevOps: 'snet-devOps-${naming.virtualNetwork.name}-spoke'
  snetPe: 'snet-pe-${naming.virtualNetwork.name}-spoke'
  appSvcUserAssignedManagedIdentity: '${naming.userAssignedManagedIdentity.name}-appSvc'
  keyvault: naming.keyVault.nameUnique
  logAnalyticsWs: naming.logAnalyticsWorkspace.name
  appInsights: naming.applicationInsights.name
  aspName: naming.appServicePlan.name
  webApp: naming.appService.nameUnique
  vmWindowsJumpbox: '${naming.windowsVirtualMachine.name}-win-jumpbox'
  redisCache: naming.redisCache.nameUnique
  sqlServer: naming.mssqlServer.nameUnique
  sqlDb:'sample-db'
}


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

var accessPolicies = [
      {
        tenantId: appSvcUserAssignedManagedIdenity.outputs.tenantId
        objectId: appSvcUserAssignedManagedIdenity.outputs.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]     
          keys: [
            'get'
            'list'
          ] 
          certificates: [
            'get'
            'list'
          ]      
        }
      }
    ]

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')

// TODO: It seems I get a compiler errpr when assigning tokens[index] (with index > 0) to variables. Ugly but necessary
resource vnetHub  'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: vnetHubSplitTokens[8]
}

module vnetSpoke '../../shared/bicep/network/vnet.bicep' = {
  name: 'vnetHubDeployment'
  params: {    
    name: resourceNames.vnetSpoke
    location: location
    tags: tags    
    vnetAddressSpace:  spokeVnetAddressSpace
    subnetsInfo: subnets
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

module appSvcUserAssignedManagedIdenity '../../shared/bicep/managed-identity.bicep' = {
  name: 'appSvcUserAssignedManagedIdenityDeployment'
  params: {
    name: resourceNames.appSvcUserAssignedManagedIdentity
    location: location
    tags: tags
  }
}

module logAnalyticsWs '../../shared/bicep/log-analytics-ws.bicep' = {
  name: 'logAnalyticsWsDeployment'
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
    accessPolicies: accessPolicies
    subnetPrivateEndpointId: snetPe.id
    virtualNetworkLinks: virtualNetworkLinks
  }
}

// TODO: Add Slots
// TODO: Add Managed Identity and access to keyvaults\
// TODO: Need to expose (bubble up) parameter for AZ - 
module webApp 'modules/app-service.module.bicep' = {
  name: 'webAppModuleDeployment'
  params: {
    appServicePlanName: resourceNames.aspName
    webAppName: resourceNames.webApp
    location: location
    logAnalyticsWsId: logAnalyticsWs.outputs.logAnalyticsWsId
    subnetIdForVnetInjection: snetAppSvc.id
    tags: tags
    vnetHubResourceId: vnetHubResourceId
    webAppBaseOS: webAppBaseOS
    subnetPrivateEndpointId: snetPe.id
    virtualNetworkLinks: virtualNetworkLinks   
  }
}

//TODO: Check with username/password AAD join and DevOps Agent
module vmWindows '../../shared/bicep/compute/jumphost-win11.bicep' = {
  name: 'vmWindowsDeployment'
  params: {
    name:  resourceNames.vmWindowsJumpbox 
    location: location
    tags: tags
    adminPassword: adminPassword
    adminUsername: adminUsername
    subnetId: snetDevOps.id
    enableAzureAdJoin: true
  }
}

// TODO: We need feature flag to deploy or not Redis - should not be default
module redisCache 'modules/redis.module.bicep' = {
  name: take('${resourceNames.redisCache}-redisModule-Deployment', 64)
  params: {
    name: resourceNames.redisCache
    location: location
    tags: tags
    logAnalyticsWsId: logAnalyticsWs.outputs.logAnalyticsWsId  
    vnetHubResourceId: vnetHubResourceId
    subnetPrivateEndpointId: snetPe.id
    virtualNetworkLinks: virtualNetworkLinks
  }
}

//TODO: conditional deployment of SQL
module sqlServerAndDefaultDb 'modules/sql-database.module.bicep' = {
  name: take('${resourceNames.sqlServer}-redisModule-Deployment', 64)
  params: {
    name: resourceNames.sqlServer
    databaseName: resourceNames.sqlDb
    location: location
    tags: tags 
    vnetHubResourceId: vnetHubResourceId
    subnetPrivateEndpointId: snetPe.id
    virtualNetworkLinks: virtualNetworkLinks
    administrators: sqlServerAdministrators
  }
}


output vnetSpokeName string = vnetSpoke.outputs.vnetName
output vnetSpokeId string = vnetSpoke.outputs.vnetId
//output sampleAppIngress string = webApp.outputs.fqdn
