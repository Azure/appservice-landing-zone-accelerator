@description('Required. The private DNS zone name which will contain the A records.')
param privateDnsZoneName string

@description('Required. Array of the A records to be created, item should be a object containing the properties "name", "ipAddress", "ttl".')
param aRecords array

resource records 'Microsoft.Network/privateDnsZones/A@2020-06-01' = [for (aRecord, i) in aRecords: {
  name: '${privateDnsZoneName}/${aRecord.name}'
  properties: {
    ttl: contains(aRecord, 'ttl') ? aRecord.ttl : 3600
    aRecords: [
      {
        ipv4Address: aRecord.ipAddress
      }
    ]
  }  
}]

output ids array = [for i in range(0, length(aRecords)): records[i].id]
