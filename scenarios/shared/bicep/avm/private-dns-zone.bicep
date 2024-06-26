@description('Required. Name of the Private DNS Zone Service. For az private endpoints you might find info here: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns#azure-services-dns-zone-configuration')
param name string

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Array of custom objects describing vNet links of the DNS zone. Each object should contain vnetName, vnetId, registrationEnabled')
param virtualNetworkLinks array = []

@description('Optional. Array of A records to be added to the DNS Zone') 
param aRecords array = []

module privateDnsZone 'br/public:avm/res/network/private-dns-zone:0.3.0' = {
  name: take('${name}-privatednszone-Deployment', 64)
  params: {
    name: name
    location: 'global'
    tags: tags
  }
}

resource privateDnsZoneExisting 'Microsoft.Network/privateDnsZones@2020-06-01' existing =  {
  name: name
} 

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = [ for vnet in virtualNetworkLinks: {
  parent: privateDnsZoneExisting
  name:  '${vnet.vnetName}-link'
  location: 'global'
  properties: {
    registrationEnabled: vnet.registrationEnabled
    virtualNetwork: {
      id: vnet.vnetId
    }
  }
}]

resource dnsARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = [for (aRecord, i) in aRecords: {
  parent: privateDnsZoneExisting
  name: aRecord.name
  properties: {
    ttl: contains(aRecord, 'ttl') ? aRecord.ttl : 3600
    aRecords: [
      {
        ipv4Address: aRecord.ipv4Address
      }
    ]
  }
}]

output privateDnsZonesId string = privateDnsZone.outputs.resourceId
