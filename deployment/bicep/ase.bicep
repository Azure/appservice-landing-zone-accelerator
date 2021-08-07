// Parameters
@description('A short name for the workload being deployed')
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

@description('Azure location to which the resources are to be deployed')
param location string

@description('Azure location to which the ASE is to be deployed. Seperated out for now while there is a bug in specifying the ASE location. "West Europe" works, while "westeurope" does not')
param aseLocation string

@description('The mode for the internal load balancing configuration to be applied to the ASE load balancer')
@allowed([
  'None'
  'Publishing'
  'Web'
  'Web, Publishing'
])
param internalLoadBalancingMode string = 'Web, Publishing'

@description('Requirements of ASE Subnet')
param aseSubnetName string
@description('Requirements of ASE Subnet')
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

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}-001'
var aseName = 'ase-${resourceSuffix}' // NOTE : ASE name cannot be more than 37 characters
var appServicePlanName = 'asp-${resourceSuffix}'

// Resources
resource ase 'Microsoft.Web/hostingEnvironments@2021-01-01' = {
  name: aseName
  location: aseLocation
  kind: 'ASEV3'
  properties: {
    internalLoadBalancingMode: internalLoadBalancingMode
    // zoneRedundant: true -- not currently supported in bicep
    virtualNetwork: {
      id: aseSubnetId
      subnet: aseSubnetName
    }
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-01' = {
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
