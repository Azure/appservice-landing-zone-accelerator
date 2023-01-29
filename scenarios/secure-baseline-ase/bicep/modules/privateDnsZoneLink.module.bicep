param privateDnsZoneName string
param tags object = {}
param registrationEnabled bool = false
param vnetIds array

resource privateDnsZoneLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  name: '${privateDnsZoneName}/${privateDnsZoneName}-link-${i}'
  location: 'Global'
  tags: tags
  properties: {
    registrationEnabled: registrationEnabled
    virtualNetwork: {
      id: vnetId
    }
  }
}]

output ids array = [for i in range(0, length(vnetIds)): privateDnsZoneLinks[i].id]
