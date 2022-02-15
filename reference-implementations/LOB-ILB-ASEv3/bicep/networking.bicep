// Parameters
@description('Azure location to which the resources are to be deployed')
param location string

@description('Standardized suffix text to be added to resource names')
param resourceSuffix string

@description('Indicator as to whether the CI/CD agent subnet should be created or not')
param createCICDAgentSubnet bool = true

@description('CIDR prefix to use for Hub VNet')
param hubVNetNameAddressPrefix string = '10.0.0.0/16'

@description('CIDR prefix to use for Spoke VNet')
param spokeVNetNameAddressPrefix string = '10.1.0.0/16'

@description('CIDR prefix to use for Bastion VNet')
param bastionAddressPrefix string = '10.0.1.0/24'

@description('CIDR prefix to use CI/CD Agent VNet')
param CICDAgentNameAddressPrefix string = '10.0.2.0/24'

@description('CIDR prefix to use for Jumpbox VNet')
param jumpBoxAddressPrefix string = '10.0.3.0/24'

@description('CIDR prefix to use for ASE')
param aseAddressPrefix string = '10.1.1.0/24'

// Variables
var bastionHostName = 'snet-basthost-${resourceSuffix}'
var bastionHostPip = '${bastionHostName}-pip'
var hubVNetName = 'vnet-hub-${resourceSuffix}'
var spokeVNetName = 'vnet-spoke-${resourceSuffix}'
var bastionSubnetName = 'AzureBastionSubnet'
var CICDAgentSubnetName = 'snet-cicd-${resourceSuffix}'
var jumpBoxSubnetName = 'snet-jbox-${resourceSuffix}'
var aseSubnetName = 'snet-ase-${resourceSuffix}'

// Resources - VNet - SubNets
resource vnetHub 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: hubVNetName
  location: location
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
        name: jumpBoxSubnetName
        properties: {
          addressPrefix: jumpBoxAddressPrefix
        }
      }
      {
        name: CICDAgentSubnetName
        properties: {
          addressPrefix: CICDAgentNameAddressPrefix
        }
      }
    ]
  }
}

// // optionally create CICD Agent subnet
// resource CICDAgentSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = if (createCICDAgentSubnet) {
//   name: CICDAgentSubnetName
//    parent: vnetHub
//    properties: {
//      addressPrefix: CICDAgentNameAddressPrefix
//    }
//    dependsOn:[
//     vnetHub
//    ]
// }

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: spokeVNetName
  location: location
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
          delegations: [
            {
              name: 'hostingEnvironment'
              properties: {
                serviceName: 'Microsoft.Web/hostingEnvironments'
              }
            }
          ]
          addressPrefix: aseAddressPrefix
        }
      }
    ]
  }
}

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
}

//bastionHost
resource bastionHostPippublicIp 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: bastionHostPip
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
resource bastionHost 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          publicIPAddress: {
            id: bastionHostPippublicIp.id
          }
          subnet: {
            id: '${vnetHub.id}/subnets/${bastionSubnetName}'
          }
        }
      }
    ]
  }
  dependsOn:[
     vnetSpoke
  ]
}

// Output section
output hubVNetName string = hubVNetName
output spokeVNetName string = spokeVNetName
output hubVNetId string = vnetHub.id
output spokeVNetId string = vnetSpoke.id
output bastionSubnetName string = bastionSubnetName
output CICDAgentSubnetName string = (createCICDAgentSubnet ? CICDAgentSubnetName : '')
output jumpBoxSubnetName string = jumpBoxSubnetName
output aseSubnetName string = aseSubnetName
output bastionSubnetId string = '${vnetHub.id}/subnets/${bastionSubnetName}'
output CICDAgentSubnetId string = (createCICDAgentSubnet ? '${vnetHub.id}/subnets/${CICDAgentSubnetName}' : '')
output jumpBoxSubnetId string = '${vnetHub.id}/subnets/${jumpBoxSubnetName}'
output aseSubnetId string = '${vnetSpoke.id}/subnets/${aseSubnetName}'
