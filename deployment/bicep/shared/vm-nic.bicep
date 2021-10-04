// Parameters
@description('Azure location to which the resources are to be deployed')
param location string

@description('Id of the subnet within which the VM must be created')
param subnetId string

@description('The private IP address to associated with this VM')
param privateIPAddress string =  '10.0.0.4'

@description('Name of the VM to be created')
param vmName string

// Resources
resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: vmName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: privateIPAddress
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

// Outputs
output nicId string = nic.id
