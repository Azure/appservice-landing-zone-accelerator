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


module keyvault 'modules/keyvault.module.bicep' = {
  name: 'keyvaultModuleDeployment'
  params: {
    location: location
    name: resourceNames.keyvault
    vnetHubResourceId: vnetHubResourceId
    subnetPrivateEnpointId: snetPe.id
    tags: tags
    accessPolicies: accessPolicies
    virtualNetworkLinks: virtualNetworkLinks
  }
}
// module keyvault '../../shared/bicep/keyvault.bicep' = {
//   name: 'keyvaultDeployment'
//   params: {
//     hasPrivateEndpoint: true
//     location: location
//     name: resourceNames.keyvault
//     tags: tags
//     // TODO: check what is required
//     accessPolicies: [
//       {
//         tenantId: appSvcUserAssignedManagedIdenity.outputs.tenantId
//         objectId: appSvcUserAssignedManagedIdenity.outputs.principalId
//         permissions: {
//           secrets: [
//             'get'
//             'list'
//           ]     
//           keys: [
//             'get'
//             'list'
//           ] 
//           certificates: [
//             'get'
//             'list'
//           ]      
//         }
//       }
//     ]
//   }
// }
