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

@description('Azure location to which the resources are to be deployed, defaulting to the resource group location')
param location string

@description('The mode for the internal load balancing configuration to be applied to the ASE load balancer')
@allowed([
  'None'
  'Publishing'
  'Web'
  'Web, Publishing'
])
param internalLoadBalancingMode string = 'Web, Publishing'

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
var vnetName = 'vnet-${resourceSuffix}'
var subnetName = 'snet-${resourceSuffix}'

// Resources
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: '${virtualNetwork.name}/${subnetName}'
  properties: {
    addressPrefix: '10.0.1.0/24'
    delegations: [
      {
        name: '${aseName}-delegation'
        properties: {
          serviceName: 'Microsoft.Web/hostingEnvironments'
        }
      }
    ]
  }
}

resource ase 'Microsoft.Web/hostingEnvironments@2021-01-01' = {
  name: aseName
  location: location
  kind: 'ASEV3'
  properties: {
    internalLoadBalancingMode: internalLoadBalancingMode
    // zoneRedundant: true -- not currently supported in bicep
    virtualNetwork: {
      id: subnet.id
      subnet: subnet.name
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
