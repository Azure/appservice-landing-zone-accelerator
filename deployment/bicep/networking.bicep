var owner = 'ASE Const Set'
@description('Azure location to which the resources are to be deployed, defaulting to the resource group location')
param location string

@description('The environment for which the deployment is being executed')
@allowed([
  'dev'
  'uat'
  'prod'
  'dr'
])
param environment string

var hubVNetName = 'vnet-hub-${environment}-${location}'
param hubVNetNameAddressPrefix string = '10.0.0.0/16'

var bastionSubnetName = 'snet-bast-${environment}-${location}'
param bastionAddressPrefix string = '10.0.1.0/24'

var devOpsSubnetName = 'snet-devops-${environment}-${location}'
param devOpsNameAddressPrefix string = '10.0.2.0/16'

var jumpBoxSubnetName = 'snet-jbox-${environment}-${location}-001'
param jumpBoxAddressPrefix string = '10.0.3.0/24'

var spokeVNetName = 'vnet-spoke-${environment}-${location}-001'
param spokeVNetNameAddressPrefix string = '10.1.0.0/16'

var aseSubnetName = 'snet-ase-${environment}-${location}-001'
param aseAddressPrefix string = '10.1.1.0/24'


resource vnetHub 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: hubVNetName
  location: resourceGroup().location
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

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2020-06-01' = {
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

resource vnetHubPeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
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
}

resource vnetSpokePeer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
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
}

output hubVNetName string = hubVNetName
output bastionSubnetName string = bastionSubnetName
output devOpsSubnetName string = devOpsSubnetName
output jumpBoxSubnetName string = jumpBoxSubnetName
output spokeVNetName string = spokeVNetName
output aseSubnetName string = aseSubnetName

output hubVNetId string = vnetHub.id

output spokeVNetId string = vnetSpoke.id

