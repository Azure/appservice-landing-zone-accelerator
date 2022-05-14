param name string
param tags object = {}
param registrationEnabled bool = false

@description('Required. The Virtual Network Ids for this Private DNS zone to be linked with.')
param vnetIds array

@description('Required. Array of the A records to be created in this Private DNS zone, array of objects containing the properties "name", "ipAddress", "ttl".')
param aRecords array

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'Global'
  tags: tags  
}

module privateDnsZoneLinks 'privateDnsZoneLink.module.bicep' = if (!empty(vnetIds)) {
  name: 'PrvDnsZoneLinks-Deployment-${name}'  
  params: {
    privateDnsZoneName: privateDnsZone.name
    vnetIds: vnetIds
    registrationEnabled: registrationEnabled
    tags: tags
  }
}

module privateDnsZoneRecords 'privateDnsZoneRecords.module.bicep' = if (!empty(aRecords)) {
  name: 'PrvDnsZoneLinks-Deployment-${name}'  
  params: {
    privateDnsZoneName: privateDnsZone.name
    aRecords: aRecords
  }
}

output id string = privateDnsZone.id
output linkIds array = privateDnsZoneLinks.outputs.ids
