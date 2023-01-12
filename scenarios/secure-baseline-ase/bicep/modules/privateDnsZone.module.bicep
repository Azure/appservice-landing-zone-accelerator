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

@description('Optional. Whether we want the records to be created automatically')
param isRedisDnsZone bool = true

@description('Required. Prefix used for the name of deployment')
param prefix string


var deploymentNames = {
  dnsZoneLinkDeploymentName: '${prefix}DnsZonePrvDnsZoneLinks-Deployment'
  dnsZoneARecordDeploymentName: '${prefix}DnsZoneARecord-Deployment'
  dnsZoneGroupDeploymentName:  '${prefix}DnsZoneGroup-Deployment'
}
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'Global'
  tags: tags  
}

module privateDnsZoneLinks 'privateDnsZoneLink.module.bicep' = if (!empty(vnetIds)) {
  name: deploymentNames.dnsZoneLinkDeploymentName  
  params: {
    privateDnsZoneName: privateDnsZone.name
    vnetIds: vnetIds
    registrationEnabled: registrationEnabled
    tags: tags
  }
}

module privateDnsZoneRecords 'privateDnsZoneRecords.module.bicep' = if (!empty(aRecords) && !isRedisDnsZone) {
  name: deploymentNames.dnsZoneARecordDeploymentName 
  params: {
    privateDnsZoneName: privateDnsZone.name
    aRecords: aRecords
  }
}

module privateDnsZoneGroup 'privateDnsZoneGroup.module.bicep' = if(isRedisDnsZone) {
  name: deploymentNames.dnsZoneGroupDeploymentName
  params: {
     privateDnsZoneName: privateDnsZone.name
     privateDnsZoneResourceId: privateDnsZone.id
  }
}

output id string = privateDnsZone.id
output linkIds array = privateDnsZoneLinks.outputs.ids
