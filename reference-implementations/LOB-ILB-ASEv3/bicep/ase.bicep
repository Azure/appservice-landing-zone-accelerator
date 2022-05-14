// Parameters
@description('Required. Azure location to which the resources are to be deployed')
param location string

@description('Optional. The mode for the internal load balancing configuration to be applied to the ASE load balancer')
@allowed([
  'None'
  'Publishing'
  'Web'
  'Web, Publishing'
])
param internalLoadBalancingMode string = 'Web, Publishing'

@description('Required. The full id string identifying the target vnet for the ASE')
param vnetId string

@description('Required. The full id string identifying the target subnet for the ASE')
param aseSubnetId string

@description('The name of the subnet to be used for ASE')
param aseSubnetName string

@description('The number of workers to be deployed in the worker pool')
param numberOfWorkers int = 3

@description('Specify the worker pool size SKU (1, 2, or 3) to be created')
@allowed([
  '1'
  '2'
  '3'
])
param workerPool string = '1'

@description('String to append to resources as part of naming standards.')
param resourceSuffix string

@description('Required. The naming module for facilitating naming convention.')
param naming object

@description('Optional. The tags to be assigned the created resources.')
param tags object = {}

// Variables 
/// niantoni: Azure Portal Designer for ASEv3 restriction is max 36 characters
var aseName = take('ase-${resourceSuffix}', 37) // NOTE : ASE name cannot be more than 37 characters
var privateDnsZoneName = '${aseName}.appserviceenvironment.net'

var resourceNames = {
  appServiceEnvironment: naming.appServiceEnvironment.name
  appServicePlan: naming.appServicePlan.name
}

// Resources
resource ase 'Microsoft.Web/hostingEnvironments@2021-02-01' = {
  name: resourceNames.appServiceEnvironment
  location: location
  kind: 'ASEV3'
  properties: {
    internalLoadBalancingMode: internalLoadBalancingMode
    zoneRedundant: true
    virtualNetwork: {
      id: aseSubnetId
      subnet: aseSubnetName
    }
  }
  tags: tags
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: resourceNames.appServicePlan
  location: location
  properties: {
    hostingEnvironmentProfile: {
      id: ase.id
    }
  }
  sku: {
    name: 'I${workerPool}V2'
    tier: 'IsolatedV2'
    size: 'I${workerPool}V2'
    capacity: numberOfWorkers 
  }
  tags: tags
}

module privateDnsZone 'modules/privateDnsZone.module.bicep' = {
  name: 'PrivateDnsZoneModule'
  params: {
    name: privateDnsZoneName // ase.properties.dnsSuffix
    vnetIds: [
      vnetId
    ]
    aRecords: [
      {
        name: '*'
        ipAddress: reference('${ase.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0]
        ttl: 3600
      }
      {
        name: '*.scm'
        ipAddress: reference('${ase.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0]
        ttl: 3600
      }
      {
        name: '@'
        ipAddress: reference('${ase.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0]
        ttl: 3600
      }
    ]
    registrationEnabled: false
    tags: tags
  }
}

// resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: privateDnsZoneName
//   location: 'global'
//   properties: {}
//   dependsOn: [
//     ase
//   ]
// }

// resource privateDnsZoneName_vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateDnsZone
//   name: 'vnetLink'
//   location: 'global'
//   properties: {
//     virtualNetwork: {
//       id: vnetId
//     }
//     registrationEnabled: false    
//   }
// }

// resource Microsoft_Network_privateDnsZones_A_privateDnsZoneName 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   parent: privateDnsZone
//   name: '*'
//   properties: {
//     ttl: 3600
//     aRecords: [
//       {
//         ipv4Address: reference('${ase.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0]
//       }
//     ]
//   }
// }

// resource privateDnsZoneName_scm 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   parent: privateDnsZone
//   name: '*.scm'
//   properties: {
//     ttl: 3600
//     aRecords: [
//       {
//         ipv4Address: reference('${ase.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0]
//       }
//     ]
//   }
// }

// resource privateDnsZoneName_Amp 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   parent: privateDnsZone
//   name: '@'
//   properties: {
//     ttl: 3600
//     aRecords: [
//       {
//         ipv4Address: reference('${ase.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0]
//       }
//     ]
//   }
// }

// Outputs
output aseName string =  ase.name
output aseId string = ase.id
output appServicePlanName string = appServicePlan.name
output appServicePlanId string = appServicePlan.id
output privateDnsZoneId string = privateDnsZone.outputs.id
