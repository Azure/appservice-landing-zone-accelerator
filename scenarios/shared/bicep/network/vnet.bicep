// ------------------
//    PARAMETERS
// ------------------

@description('Name of the resource Virtual Network (The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens)')
@minLength(2)
@maxLength(80)
param name string

@description('Azure Region where the resource will be deployed in')
param location string

@description('key-value pairs as tags, to identify the resource')
param tags object

@description('CIDR to be allocated to the new vnet i.e. 192.168.0.0/24')
param vnetAddressSpace string

@description('Pass an array of objects for all the required subnets')
param subnetsInfo array

@description('Optional. Resource ID of the DDoS protection plan to assign the VNET to. If it\'s left blank, DDoS protection will not be configured. If it\'s provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription.')
param ddosProtectionPlanId string = ''


// ------------------
// VARIABLES
// ------------------

var vnetNameMaxLength = 80
var vnetName = take (name, vnetNameMaxLength)
var ddosProtectionPlan = {
  id: ddosProtectionPlanId
}

// ------------------
// RESOURCES
// ------------------

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    ddosProtectionPlan: !empty(ddosProtectionPlanId) ? ddosProtectionPlan : null
    enableDdosProtection: !empty(ddosProtectionPlanId)
    subnets: subnetsInfo
  }
  tags: tags
}


// ------------------
// OUTPUTS
// ------------------

@description('Resource id of the newly created Virtual network')
output vnetId string = vnet.id

@description('Resource name of the newly created Virtual network')
output vnetName string = vnet.name


// INFO: based on second example of https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/loops#array-and-index
@description('Outputs the array of the subnets, printing: index, subnetResourceId, subnerName. ')
output vnetSubnets array = [ for (item, i) in subnetsInfo: {
  subnetIndex: i
  id: vnet.properties.subnets[i].id
  name: vnet.properties.subnets[i].name  
}]
