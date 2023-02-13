@description('Required. Name of the Bastion Service.')
param name string

@description('Azure region where the resources will be deployed in')
param location string

param tags object = {}

@description('The virtual network ID containing AzureBastionSubnet. ')
param vnetId string = ''

var bastionNameMaxLength = 80
var bastionNameSantized = length(name) > bastionNameMaxLength ? substring(name, 0, bastionNameMaxLength) : name

//auxiliary but mandatory resource that needs to be created
resource publicIp 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: 'pip-${name}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
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
            id: publicIp.id
          }
        }
      }
    ]
  }
}

@description('The standard public IP assigned to the Bastion Service')
output bastionPublicIp string = publicIp.properties.ipAddress
