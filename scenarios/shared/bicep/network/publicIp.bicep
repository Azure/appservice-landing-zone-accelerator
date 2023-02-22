@description('Required. Name of the Bastion Service.')
param name string

@description('Azure region where the resources will be deployed in')
param location string

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Optional. Resource ID of the Public IP Prefix object. This is only needed if you want your Public IPs created in a PIP Prefix.')
param publicIPPrefixResourceId string = ''

@description('Optional, default is dynamic. The public IP address allocation method.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Dynamic'

@description('Optional defaulr is Basic. Name of a public IP address SKU.')
@allowed([
  'Basic'
  'Standard'
])
param skuName string = 'Basic'

@description('Optional, default is Regional. Tier of a public IP address SKU.')
@allowed([
  'Global'
  'Regional'
])
param skuTier string = 'Regional'

@description('Optional, default no zones. A list of availability zones denoting the IP allocated for the resource needs to come from.')
param zones array = []

@description('Optional, default is IPv4. IP address version.')
@allowed([
  'IPv4'
  'IPv6'
])
param publicIPAddressVersion string = 'IPv4'

@description('Optional. The domain name label. The concatenation of the domain name label and the regionalized DNS zone make up the fully qualified domain name associated with the public IP address. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system.')
param domainNameLabel string = ''

@description('Optional. The Fully Qualified Domain Name of the A DNS record associated with the public IP. This is the concatenation of the domainNameLabel and the regionalized DNS zone.')
param fqdn string = ''

@description('Optional. The reverse FQDN. A user-visible, fully qualified domain name that resolves to this public IP address. If the reverseFqdn is specified, then a PTR DNS record is created pointing from the IP address in the in-addr.arpa domain to the reverse FQDN.')
param reverseFqdn string = ''

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  zones: zones
  properties: {
    dnsSettings: !empty(domainNameLabel) ? {
      domainNameLabel: domainNameLabel
      fqdn: fqdn
      reverseFqdn: reverseFqdn
    } : null
    publicIPAddressVersion: publicIPAddressVersion
    publicIPAllocationMethod: publicIPAllocationMethod
    publicIPPrefix: !empty(publicIPPrefixResourceId) ? {
      id: publicIPPrefixResourceId
    } : null
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}


@description('The name of the public IP address.')
output pipName string = publicIpAddress.name

@description('The resource ID of the public IP address.')
output pipResourceId string = publicIpAddress.id

@description('The public IP address of the public IP address resource.')
output ipAddress string = contains(publicIpAddress.properties, 'ipAddress') ? publicIpAddress.properties.ipAddress : ''

