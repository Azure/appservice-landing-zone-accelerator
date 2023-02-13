@description('Required. Name of the Bastion Service.')
param name string

@description('Azure region where the resources will be deployed in')
param location string

param tags object = {}

@description('The virtual network ID containing AzureBastionSubnet. ')
param vnetId string = ''

var bastionNameMaxLength = 80
var bastionNameSantized = length(name) > bastionNameMaxLength ? substring(name, 0, bastionNameMaxLength) : name


module publicIp 'publicIp.bicep' = {
  name: 'pipBastionHostDeployment'
  params: {
    location: location
    name: 'pip-${bastionNameSantized}'
    skuTier: 'Regional'
    skuName: 'Standard'
    publicIPAllocationMethod: 'Static'    
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: bastionNameSantized
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: '${vnetId}/subnets/AzureBastionSubnet' 
          }
          publicIPAddress: {
            id: publicIp.outputs.pipResourceId
          }
        }
      }
    ]
  }
}

@description('The standard public IP assigned to the Bastion Service')
output bastionPublicIp string = publicIp.outputs.ipAddress
