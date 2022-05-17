@description('Required. Name of the Private DNS Zone.')
param name string

@description('Optional. The tags to be assigned the created resources.')
param tags object = {}

@description('Required. The Virtual Network Ids for this Private DNS zone to be linked with.')
param vnetIds array

@description('Required. Array of the A records to be created in this Private DNS zone, array of objects containing the properties "name", "ipAddress", "ttl".')
param aRecords array

@description('Optional. Whether the automatic registration of resources in the Private DNS Zone is enabled -defaults to false')
param registrationEnabled bool = false

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'Global'
  tags: tags  
}

module privateDnsZoneLinks 'privateDnsZoneLink.module.bicep' = if (!empty(vnetIds)) {
  name: 'AseDnsZonePrvDnsZoneLinks-Deployment'  
  params: {
    privateDnsZoneName: privateDnsZone.name
    vnetIds: vnetIds
    registrationEnabled: registrationEnabled
    tags: tags
  }
}

module privateDnsZoneRecords 'privateDnsZoneRecords.module.bicep' = if (!empty(aRecords)) {
  name: 'AseDnsZoneARecord-Deployment'  
  params: {
    privateDnsZoneName: privateDnsZone.name
    aRecords: aRecords
  }
}

output id string = privateDnsZone.id
output linkIds array = privateDnsZoneLinks.outputs.ids
