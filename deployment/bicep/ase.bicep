// Parameters
@description('Azure location to which the resources are to be deployed')
param location string

@description('The mode for the internal load balancing configuration to be applied to the ASE load balancer')
@allowed([
  'None'
  'Publishing'
  'Web'
  'Web, Publishing'
])
param internalLoadBalancingMode string = 'Web, Publishing'

@description('The name of the subnet to be used for ASE')
param aseSubnetName string

@description('The full id string identifying the target subnet for the ASE')
param aseSubnetId string

@description('The full id string identifying the target vnet for the ASE')
param vnetId string

@description('The number of workers to be deployed in the worker pool')
param numberOfWorkers int = 1

@description('Specify the worker pool size SKU (1, 2, or 3) to be created')
@allowed([
  '1'
  '2'
  '3'
])
param workerPool string = '1'

@description('String to append to resources as part of naming standards')
param resourceSuffix string

// Variables
var aseName = take('ase-${resourceSuffix}', 37) // NOTE : ASE name cannot be more than 37 characters
var appServicePlanName = 'asp-${resourceSuffix}'
var privateDnsZoneName = '${aseName}.appserviceenvironment.net'

// Resources
resource ase 'Microsoft.Web/hostingEnvironments@2021-01-15' = {
  name: aseName
  location: location
  kind: 'ASEV3'
  properties: {
    internalLoadBalancingMode: internalLoadBalancingMode
    // zoneRedundant: true // not currently supported in bicep
    virtualNetwork: {
      id: aseSubnetId
      subnet: aseSubnetName
    }
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: appServicePlanName
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
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    ase
  ]
}

resource privateDnsZoneName_vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'vnetLink'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

resource Microsoft_Network_privateDnsZones_A_privateDnsZoneName 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZone
  name: '*'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference('${ase.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0]
      }
    ]
  }
}

resource privateDnsZoneName_scm 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZone
  name: '*.scm'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference('${ase.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0]
      }
    ]
  }
}

resource privateDnsZoneName_Amp 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: privateDnsZone
  name: '@'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: reference('${ase.id}/configurations/networking', '2020-06-01').internalInboundIpAddresses[0]
      }
    ]
  }
}

// Outputs
output aseName string = aseName
output aseId string = ase.id
output appServicePlanName string = appServicePlanName
output appServicePlanId string = appServicePlan.id
