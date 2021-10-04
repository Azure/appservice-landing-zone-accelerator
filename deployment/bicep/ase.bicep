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

// Resources
resource ase 'Microsoft.Web/hostingEnvironments@2021-01-15' = {
  name: aseName
  location: location
  kind: 'ASEV3'
  properties: {
    internalLoadBalancingMode: internalLoadBalancingMode
    zoneRedundant: true // not currently supported in bicep
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

// Outputs
output aseName string = aseName
output aseId string = ase.id
output appServicePlanName string = appServicePlanName
output appServicePlanId string = appServicePlan.id
