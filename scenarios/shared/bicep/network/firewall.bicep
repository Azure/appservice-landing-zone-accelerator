@description('Required. Name of the Azure Firewall.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the Azure Firewall resource.')
param tags object = {}

@description('Optional. Tier of an Azure Firewall.')
@allowed([
  'Standard'
  'Premium'
])
param azureSkuTier string = 'Standard'

@description('The virtual network ID containing AzureFirewallSubnet. If a public ip is not provided, then the public ip that is created as part of this module will be applied with the subnet provided in this variable.')
param vnetId string = ''

@description('Optional. Collection of application rule collections used by Azure Firewall.')
param applicationRuleCollections array = []

@description('Optional. Collection of network rule collections used by Azure Firewall.')
param networkRuleCollections array = []

@description('Optional. Collection of NAT rule collections used by Azure Firewall.')
param natRuleCollections array = []

@description('Optional. Resource ID of the Firewall Policy that should be attached.')
param firewallPolicyId string = ''

@allowed([
  'Alert'
  'Deny'
  'Off'
])
@description('Optional. The operation mode for Threat Intel.')
param threatIntelMode string = 'Deny'

@description('Optional. Zone numbers e.g. 1,2,3.')
param zones array = []
// param zones array = [
//   '1'
//   '2'
//   '3'
// ]


@description('Optional. Diagnostic Storage Account resource identifier.')
param diagnosticStorageAccountId string = ''

@description('Optional. Log Analytics workspace resource identifier.')
param diagnosticWorkspaceId string = ''

@description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource.')
@allowed([
  'allLogs'
  'AzureFirewallApplicationRule'
  'AzureFirewallNetworkRule'
  'AzureFirewallDnsProxy'
])
param diagnosticLogCategoriesToEnable array = [
  'allLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. The name of the diagnostic setting, if deployed.')
param diagnosticSettingsName string = '${name}-diagnosticSettings'

var azFwNameMaxLength = 56
var azFwNameSantized = length(name) > azFwNameMaxLength ? substring(name, 0, azFwNameMaxLength) : name

// The default is AZFW_VNet. If you want to attach azure firewall to vhub, you should set sku to AZFW_Hub. accepted values: AZFW_Hub, AZFW_VNet
var azureSkuName = 'AZFW_VNet'

// ----------------------------------------------------------------------------

var diagnosticsLogsSpecified = [for category in filter(diagnosticLogCategoriesToEnable, item => item != 'allLogs'): {
  category: category
  enabled: true
}]

var diagnosticsLogs = contains(diagnosticLogCategoriesToEnable, 'allLogs') ? [
  {
    categoryGroup: 'allLogs'
    enabled: true
  }
] : diagnosticsLogsSpecified

var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

var ipConfigurations = [{
  name: 'azFwIpConf1'
  properties: {
    subnet: {
      id: '${vnetId}/subnets/AzureFirewallSubnet' 
    }
    publicIPAddress: {
      id: publicIp.outputs.pipResourceId
    }
  }
}]

module publicIp 'publicIp.bicep' = {
  name: 'pipAzFwDeployment'
  params: {
    location: location
    name: 'pip-${azFwNameSantized}'
    skuTier: 'Regional'
    skuName: 'Standard'
    publicIPAllocationMethod: 'Static'    
  }
}

resource azureFirewall_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticStorageAccountId) || !empty(diagnosticWorkspaceId) || !empty(diagnosticEventHubAuthorizationRuleId) || !empty(diagnosticEventHubName)) {
  name: diagnosticSettingsName
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(diagnosticWorkspaceId) ? diagnosticWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
  scope: azureFirewall
}

resource azureFirewall 'Microsoft.Network/azureFirewalls@2022-07-01' = {
  name: azFwNameSantized
  location: location
  zones: length(zones) == 0 ? null : zones
  tags: tags
  properties: {
    threatIntelMode: threatIntelMode
    firewallPolicy: !empty(firewallPolicyId) ? {
      id: firewallPolicyId
    } : null
    ipConfigurations: ipConfigurations
    sku: {
      name: azureSkuName
      tier: azureSkuTier
    }
    applicationRuleCollections: applicationRuleCollections
    natRuleCollections: natRuleCollections
    networkRuleCollections: networkRuleCollections
  }
}


@description('The resource ID of the Azure Firewall.')
output azureFirewallId string = azureFirewall.id

@description('The name of the Azure Firewall.')
output azureFirewallName string = azureFirewall.name

@description('The private IP of the Azure firewall.')
output azFwPrivateIp string = contains(azureFirewall.properties, 'ipConfigurations') ? azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress : ''

@description('The public IP configuration object for the Azure Firewall Subnet.')
output ipConfAzureFirewallSubnet object = contains(azureFirewall.properties, 'ipConfigurations') ? azureFirewall.properties.ipConfigurations[0] : {}

@description('List of Application Rule Collections.')
output azFwApplicationRuleCollections array = applicationRuleCollections

@description('List of Network Rule Collections.')
output azFwANetworkRuleCollections array = networkRuleCollections

@description('Collection of NAT rule collections used by Azure Firewall.')
output azFwANatRuleCollections array = natRuleCollections
