// TODO: windows vs linux

@description('A short name for the workload being deployed')
param workloadName string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string = 'dev'

@description('Azure location to which the resources are to be deployed, defaulting to the resource group location')
param location string = resourceGroup().location

@description('The mode for the internal load balancing configuration to be applied to the ASE load balancer')
@allowed([
  'None'
  'Publishing'
  'Web'
  'Web, Publishing'
])
param internalLoadBalancingMode string = 'Web, Publishing'

@description('The number of workers to be deployed in the worker pool this ASE')
param numberOfWorkers int = 1

@description('Specify the worker pool size (1, 2, or 3) to be created, as per ')
@allowed([
  '1'
  '2'
  '3'
])
param workerPool string = '1'

// Variables
var resourceSuffix = '${workloadName}-${environment}-${location}'
var aseName = 'ase-${resourceSuffix}'
var appServicePlanName = 'asp-${resourceSuffix}'

// Resources
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'vnet-01'
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
  name: '${virtualNetwork.name}/subnet-01'
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
    name: 'I${workerPool}'
    tier: 'Isolated'
    size: 'I${workerPool}'
    family: 'I'
    capacity: numberOfWorkers 
  }
}

// Outputs
output aseName string = aseName
output aseId string = ase.id
output appServicePlanName string = appServicePlanName
