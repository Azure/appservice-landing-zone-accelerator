// Parameters
@description('Optional. Azure location to which the resources are to be deployed')
param location string

@description('Required. The naming module for facilitating resource naming convention.')
param naming object

@description('Optional. Indicator as to whether the CI/CD agent subnet should be created or not, defaults to true.')
param createCICDAgentSubnet bool = true

@description('CIDR prefix to use for Hub VNet')
param hubVNetAddressPrefix string = '10.0.0.0/16'

@description('CIDR prefix to use for Spoke VNet')
param spokeVNetAddressPrefix string = '10.1.0.0/16'

@description('CIDR prefix to use for Bastion subnet')
param bastionAddressPrefix string = '10.0.1.0/24'

@description('CIDR prefix to use for Jumpbox subnet')
param jumpBoxAddressPrefix string = '10.0.2.0/24'

@description('CIDR prefix to use CI/CD Agent subnet')
param CICDAgentAddressPrefix string = '10.0.3.0/24'

@description('CIDR prefix to use for ASE')
param aseAddressPrefix string = '10.1.1.0/24'

@description('Optional. The tags to be assigned the created resources.')
param tags object = {}

// Variables
var placeholder = '***'
var vnetNameWithPlaceholder = replace(naming.virtualNetwork.name, '${naming.virtualNetwork.slug}-', '${naming.virtualNetwork.slug}-${placeholder}-')
var snetNameWithPlaceholder = replace(naming.subnet.name, '${naming.subnet.slug}-', '${naming.subnet.slug}-${placeholder}-')
var resourceNames = {
  bastionHost: naming.bastionHost.name
  bastionHostPublicIp: '${naming.publicIp.slug}-${naming.bastionHost.name}'
  vnetHub: replace(vnetNameWithPlaceholder, placeholder, 'hub')
  vnetSpoke: replace(vnetNameWithPlaceholder, placeholder, 'spoke')
  bastionSubnet: 'AzureBastionSubnet'
  aseSubnet: replace(snetNameWithPlaceholder, placeholder, 'ase')
  cicdAgentSubnet: replace(snetNameWithPlaceholder, placeholder, 'cicd')
  jumpboxSubnet: replace(snetNameWithPlaceholder, placeholder, 'jbox')
}

var defaultSubnets = [
  {
    name: resourceNames.bastionSubnet
    properties: {
      addressPrefix: bastionAddressPrefix
    }
  }
  {
    name: resourceNames.jumpboxSubnet
    properties: {
      addressPrefix: jumpBoxAddressPrefix
    }
  }
]

// Append optional CICD Agent subnet, if required
var subnets = createCICDAgentSubnet ? concat(defaultSubnets, [
  {
    name: resourceNames.cicdAgentSubnet
    properties: {
      addressPrefix: CICDAgentAddressPrefix
    }
  }
]) : defaultSubnets

// Resources - VNet - SubNets
resource vnetHub 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: resourceNames.vnetHub
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVNetAddressPrefix
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: subnets
  }
}

resource vnetSpoke 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: resourceNames.vnetSpoke
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeVNetAddressPrefix
      ]
    }
    enableVmProtection: false
    enableDdosProtection: false
    subnets: [
      {
        name: resourceNames.aseSubnet
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
resource bastionHostPublicIp 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: resourceNames.bastionHostPublicIp
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
resource bastionHost 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: resourceNames.bastionHost
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          publicIPAddress: {
            id: bastionHostPublicIp.id
          }
          subnet: {
            id: '${vnetHub.id}/subnets/${resourceNames.bastionSubnet}'
          }
        }
      }
    ]
  }
  dependsOn: [
    vnetSpoke
  ]
}

// Output section
output hubVNetName string = vnetHub.name
output spokeVNetName string = vnetSpoke.name
output hubVNetId string = vnetHub.id
output spokeVNetId string = vnetSpoke.id
output bastionSubnetName string = resourceNames.bastionSubnet
output bastionSubnetId string = '${vnetHub.id}/subnets/${resourceNames.bastionSubnet}'
output CICDAgentSubnetName string = (createCICDAgentSubnet ? resourceNames.cicdAgentSubnet : '')
output CICDAgentSubnetId string = (createCICDAgentSubnet ? '${vnetHub.id}/subnets/${resourceNames.cicdAgentSubnet}' : '')
output jumpBoxSubnetName string = resourceNames.jumpboxSubnet
output jumpBoxSubnetId string = '${vnetHub.id}/subnets/${resourceNames.jumpboxSubnet}'
output aseSubnetName string = resourceNames.aseSubnet
output aseSubnetId string = '${vnetSpoke.id}/subnets/${resourceNames.aseSubnet}'
