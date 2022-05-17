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

@description('Required. The full id string identifying the spoke vnet (where the ASE resides).')
param vnetId string

@description('Required. The full id string identifying the target subnet for the ASE.')
param aseSubnetId string

@description('The number of workers to be deployed in the worker pool')
param numberOfWorkers int = 3

@description('Specify the worker pool size SKU (1, 2, or 3) to be created')
@allowed([
  '1'
  '2'
  '3'
])
param workerPool string = '1'

@description('Required. The naming module for facilitating naming convention.')
param naming object

@description('Optional. The tags to be assigned the created resources.')
param tags object = {}

// Variables 
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
    }
  }
  tags: tags
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
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
    name: '${ase.name}.appserviceenvironment.net'
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

// Outputs
output aseName string = ase.name
output aseId string = ase.id
output appServicePlanName string = appServicePlan.name
output appServicePlanId string = appServicePlan.id
output privateDnsZoneId string = privateDnsZone.outputs.id
