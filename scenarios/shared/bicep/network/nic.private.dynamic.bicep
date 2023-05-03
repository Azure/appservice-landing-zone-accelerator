@description('Required. The name of the network interface.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Indicates whether IP forwarding is enabled on this network interface.')
param enableIPForwarding bool = false

@description('Optional. If the network interface is accelerated networking enabled.')
param enableAcceleratedNetworking bool = false

@description('Optional. List of DNS servers IP addresses. Use \'AzureProvidedDNS\' to switch to azure provided DNS resolution. \'AzureProvidedDNS\' value cannot be combined with other IPs, it must be the only value in dnsServers collection.')
param dnsServers array = []

@description('Optional. The network security group (NSG) to attach to the network interface.')
param networkSecurityGroupResourceId string = ''

@description('Mandatory. subnet resource Id where the nic will be attached to.')
param subnetId string

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    enableIPForwarding: enableIPForwarding
    enableAcceleratedNetworking: enableAcceleratedNetworking
    dnsSettings: !empty(dnsServers) ? {
      dnsServers: dnsServers
    } : null
    networkSecurityGroup: !empty(networkSecurityGroupResourceId) ? {
      id: networkSecurityGroupResourceId
    } : null
    ipConfigurations: [
      {
        name: 'ipconfig01'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

@description('The name of the deployed resource.')
output nicName string = networkInterface.name

@description('The resource ID of the deployed resource.')
output nicId string = networkInterface.id
