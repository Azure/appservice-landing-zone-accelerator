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

param hubVNetNameAddressPrefix string = '10.0.0.0/16'
param spokeVNetNameAddressPrefix string = '10.1.0.0/16'

param bastionAddressPrefix string = '10.0.1.0/24'
param devOpsNameAddressPrefix string = '10.0.2.0/24'
param jumpBoxAddressPrefix string = '10.0.3.0/24'

param aseAddressPrefix string = '10.1.1.0/24'

// Variables
var owner = 'ASE Const Set'
var location = resourceGroup().location

var hubVNetName = 'vnet-hub-${workloadName}-${environment}-${location}'
var spokeVNetName = 'vnet-spoke-${workloadName}-${environment}-${location}-001'

var bastionSubnetName = 'snet-bast-${workloadName}-${environment}-${location}'
var devOpsSubnetName = 'snet-devops-${workloadName}-${environment}-${location}'
var jumpBoxSubnetName = 'snet-jbox-${workloadName}-${environment}-${location}-001'

var aseSubnetName = 'snet-ase-${workloadName}-${environment}-${location}-001'


// Resources - VNet - SubNets
resource vnetHub 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: hubVNetName
  location: location
  tags: {
    Owner: owner
    // CostCenter: costCenter
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVNetNameAddressPrefix
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: [
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionAddressPrefix
        }
      }
      {
        name: devOpsSubnetName
        properties: {
          addressPrefix: devOpsNameAddressPrefix
        }
      }
      {
        name: jumpBoxSubnetName
        properties: {
          addressPrefix: jumpBoxAddressPrefix
        }
      }
    ]
  }
}

// resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
//   name: bastionSubnetName
//    parent: vnetHub
//    properties: {
//      addressPrefix: bastionAddressPrefix
//    }
//    dependsOn:[
//      vnetHub
//     ]
// }
// resource devOpsSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
//   name: devOpsSubnetName
//    parent: vnetHub
//    properties: {
//      addressPrefix: devOpsNameAddressPrefix
//    }
//    dependsOn:[
//     vnetHub
//     bastionSubnet
//    ]
// }
// resource jumpBoxSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
//   name: jumpBoxSubnetName
//    parent: vnetHub
//    properties: {
//      addressPrefix: jumpBoxAddressPrefix
//    }
//    dependsOn:[
//     vnetHub
//     bastionSubnet
//     devOpsSubnet
//    ]
// }

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: spokeVNetName
  location: resourceGroup().location
  tags: {
    Owner: owner
    // CostCenter: costCenter
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeVNetNameAddressPrefix
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: [
      {
        name: aseSubnetName
        properties: {
          addressPrefix: aseAddressPrefix
        }
      }
    ]
  }
}

// resource aseSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
//   name: aseSubnetName
//    parent: vnetSpoke
//    properties: {
//      addressPrefix: aseAddressPrefix
//    }
//    dependsOn:[
//     vnetSpoke
//    ]
// }

// Peering
resource vnetHubPeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${vnetHub.name}/${vnetHub.name}-${vnetSpoke.name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetSpoke.id
    }
  }
  dependsOn:[
    vnetHub
    vnetSpoke
   ]
}

resource vnetSpokePeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${vnetSpoke.name}/${vnetSpoke.name}-${vnetHub.name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnetHub.id
    }
  }
  dependsOn:[
    vnetHub
    vnetSpoke
   ]
}


// Output section
output hubVNetName string = hubVNetName
output spokeVNetName string = spokeVNetName

output hubVNetId string = vnetHub.id
output spokeVNetId string = vnetSpoke.id

output bastionSubnetName string = bastionSubnetName
output devOpsSubnetName string = devOpsSubnetName
output jumpBoxSubnetName string = jumpBoxSubnetName
output aseSubnetName string = aseSubnetName

output bastionSubnetid string = '${vnetHub.id}/subnets/${bastionSubnetName}'
output devOpsSubnetid string = '${vnetHub.id}/subnets/${devOpsSubnetName}'
output jumpBoxSubnetid string = '${vnetHub.id}/subnets/${jumpBoxSubnetName}'
output aseSubnetid string = '${vnetSpoke.id}/subnets/${aseSubnetName}'

