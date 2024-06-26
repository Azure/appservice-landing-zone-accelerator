targetScope = 'resourceGroup'

// ------------------
//    PARAMETERS
// ------------------

// reference to the BICEP naming module
param naming object

@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

@description('Resource tags that we might need to add to all resources (i.e. Environment Cost center application name etc)')
param tags object

@description('CIDR of the HUB vnet i.e. 192.168.0.0/24')
param vnetHubAddressSpace string

@description('CIDR of the subnet hosting the azure Firewall')
param subnetHubFirewallAddressSpace string

@description('CIDR to use for the AzureFirewallManagementSubnet, which is required by AzFW Basic.')
param subnetHubFirewallManagementAddressSpace string

@description('CIDR of the subnet hosting the Bastion Service')
param subnetHubBastionAddressSpace string

@description('CIDR of the SPOKE vnet i.e. 192.168.0.0/24')
param vnetSpokeAddressSpace string

@description('CIDR of the subnet that will hold devOps agents etc ')
param subnetSpokeDevOpsAddressSpace string

param zones array = [
  '1'
  '2'
  '3'
]

@description('Optional. Tier of an Azure Firewall.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param azureSkuTier string = 'Standard'

@description('Optional. Resource ID of the DDoS protection plan to assign the VNET to. If it\'s left blank, DDoS protection will not be configured. If it\'s provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription.')
param ddosProtectionPlanId string = ''

// ------------------
//    VARIABLES
// ------------------

var resourceNames = {
  bastionService: naming.bastionHost.name
  laws: take ('${naming.logAnalyticsWorkspace.name}-hub', 63)
  azFw: naming.firewall.name
  vnetHub: take('${naming.virtualNetwork.name}-hub', 80)
  subnetFirewall: 'AzureFirewallSubnet'
  subnetFirewallManagement: 'AzureFirewallManagementSubnet'
  subnetBastion: 'AzureBastionSubnet'
}

var subnets = [ 
  {
    name: resourceNames.subnetFirewall
    properties: {
      addressPrefix: subnetHubFirewallAddressSpace
      privateEndpointNetworkPolicies: 'Disabled'  
    } 
  }
  {
    name: resourceNames.subnetFirewallManagement
    properties: {
      addressPrefix: subnetHubFirewallManagementAddressSpace 
    }
  }
  {
    name: resourceNames.subnetBastion
    properties: {
      addressPrefix: subnetHubBastionAddressSpace
      privateEndpointNetworkPolicies: 'Disabled'    
    }
  }
]

@description('Application Rules for the Firewall')
var applicationRules =  [
      {
        name: 'Azure-Monitor-FQDNs'
        properties: {
          action: {
            type: 'allow'
          }
          priority: 201
          rules: [
            {
              fqdnTags: [ ]
              targetFqdns: [
                'dc.applicationinsights.azure.com'
                'dc.applicationinsights.microsoft.com'
                'dc.services.visualstudio.com'
                '*.in.applicationinsights.azure.com'
                'live.applicationinsights.azure.com'
                'rt.applicationinsights.microsoft.com'
                'rt.services.visualstudio.com'
                '*.livediagnostics.monitor.azure.com'
                '*.monitoring.azure.com'
                'agent.azureserviceprofiler.net'
                '*.agent.azureserviceprofiler.net'
                '*.monitor.azure.com'
              ]
              name: 'allow-azure-monitor'
              protocols: [               
                {
                  port: '443'
                  protocolType: 'HTTPS'
                }
              ]
              sourceAddresses: [
                vnetHubAddressSpace
                vnetSpokeAddressSpace
              ]
            }
            {
              name: 'allow-azure-ad-join'
              protocols: [
                {
                  port: '443'
                  protocolType: 'HTTPS'
                }
              ]
              sourceAddresses: [
                subnetSpokeDevOpsAddressSpace
              ]
              targetFqdns: [
                'enterpriseregistration.windows.net'
                'pas.windows.net'
                #disable-next-line no-hardcoded-env-urls
                'login.microsoftonline.com'
                #disable-next-line no-hardcoded-env-urls
                'device.login.microsoftonline.com'
                'autologon.microsoftazuread-sso.com'
                'manage-beta.microsoft.com'
                'manage.microsoft.com'
                'aadcdn.msauth.net'
                'aadcdn.msftauth.net'
                'aadcdn.msftauthimages.net'
                '*.sts.microsoft.com'
                '*.manage-beta.microsoft.com'
                '*.manage.microsoft.com'
              ]
            }
          ]
        }
      }
      {
        name: 'Devops-VM-Dependencies-FQDNs'
        properties: {
          action: {
            type: 'allow'
          }
          priority: 202
          rules: [
            {
              fqdnTags: [ ]
              targetFqdns: [
                'enterpriseregistration.windows.net'
                'pas.windows.net'
                #disable-next-line no-hardcoded-env-urls
                'login.microsoftonline.com'
                #disable-next-line no-hardcoded-env-urls
                'device.login.microsoftonline.com'
                'autologon.microsoftazuread-sso.com'
                'manage-beta.microsoft.com'
                'manage.microsoft.com'
                'aadcdn.msauth.net'
                'aadcdn.msftauth.net'
                'aadcdn.msftauthimages.net'
                '*.sts.microsoft.com'
                '*.manage-beta.microsoft.com'
                '*.manage.microsoft.com'
              ]
              name: 'allow-azure-ad-join'
              protocols: [               
                {
                  port: '443'
                  protocolType: 'HTTPS'
                }
              ]
              sourceAddresses: [
                subnetSpokeDevOpsAddressSpace
              ]
            }
            {
              name: 'allow-vm-dependencies-and-tools'
              protocols: [
                {
                  port: '443'
                  protocolType: 'HTTPS'
                }
              ]
              sourceAddresses: [
                subnetSpokeDevOpsAddressSpace
              ]
              targetFqdns: [
                'aka.ms'
                'go.microsoft.com'
                'download.microsoft.com'
                'edge.microsoft.com'
                'fs.microsoft.com'
                'wdcp.microsoft.com'
                'wdcpalt.microsoft.com'
                'msedge.api.cdp.microsoft.com'
                'winatp-gw-cane.microsoft.com'
                '*.google.com'
                '*.live.com'
                '*.bing.com'
                '*.msappproxy.net'
                '*.delivery.mp.microsoft.com'
                '*.data.microsoft.com'
                '*.blob.storage.azure.net'
                #disable-next-line no-hardcoded-env-urls
                '*.blob.core.windows.net'
                '*.dl.delivery.mp.microsoft.com'
                '*.prod.do.dsp.mp.microsoft.com'
                '*.update.microsoft.com'
                '*.windowsupdate.com'
                '*.apps.qualys.com'
                '*.bootstrapcdn.com'
                '*.jsdelivr.net'
                '*.jquery.com'
                '*.msecnd.net'
              ]
            }
          ]
        }
      }
       {
        name: 'Core-Dependencies-FQDNs'
        properties: {
          action: {
            type: 'allow'
          }
          priority: 200
          rules: [
            {
              fqdnTags: [ ]
              targetFqdns: [
              #disable-next-line no-hardcoded-env-urls
                'management.azure.com'
                #disable-next-line no-hardcoded-env-urls
                'management.core.windows.net'
                #disable-next-line no-hardcoded-env-urls
                'login.microsoftonline.com'
                'login.windows.net'
                'login.live.com'
                #disable-next-line no-hardcoded-env-urls
                'graph.windows.net'
              ]
              name: 'allow-core-apis'
              protocols: [               
                {
                  port: '443'
                  protocolType: 'HTTPS'
                }
              ]
              sourceAddresses: [
                vnetSpokeAddressSpace
                vnetHubAddressSpace
              ]
            }
            {
              name: 'allow-developer-services'
              protocols: [
                {
                  port: '443'
                  protocolType: 'HTTPS'
                }
              ]
              sourceAddresses: [
                vnetSpokeAddressSpace
                vnetHubAddressSpace
              ]
              targetFqdns: [
                'github.com'
                '*.github.com'
                '*.nuget.org'
                #disable-next-line no-hardcoded-env-urls
                '*.blob.core.windows.net'
                'raw.githubusercontent.com'
                'dev.azure.com'
                'portal.azure.com'
                '*.portal.azure.com'
                '*.portal.azure.net'
                'appservice.azureedge.net'
                '*.azurewebsites.net'
                #disable-next-line no-hardcoded-env-urls
                'edge.management.azure.com'
              ]
            }
            {
              name: 'allow-certificate-dependencies'
              protocols: [
                {
                  port: '80'
                  protocolType: 'HTTP'
                }
                 {
                  port: '443'
                  protocolType: 'HTTPS'
                }
              ]
              sourceAddresses: [
                vnetSpokeAddressSpace
                vnetHubAddressSpace
              ]
              targetFqdns: [
                '*.delivery.mp.microsoft.com'
                'ctldl.windowsupdate.com'
                'ocsp.msocsp.com'
                'oneocsp.microsoft.com'
                'crl.microsoft.com'
                'www.microsoft.com'
                '*.digicert.com'
                '*.symantec.com'
                '*.symcb.com'
                '*.d-trust.net'
              ]
            }
          ]
        }
      }
    ]

@description('Network Rules for the Firewall')    
var networkRules =  [
      {
        name: 'Windows-VM-Connectivity-Requirements'
        properties: {
          action: {
            type: 'allow'
          }
          priority: 202
          rules: [
            {
              destinationAddresses: [
                '20.118.99.224'
                '40.83.235.53'
                '23.102.135.246'
                '51.4.143.248'
                '23.97.0.13'
                '52.126.105.2'
              ]
              destinationPorts: [
                '*'
              ]
              name: 'allow-kms-activation'
              protocols: [
                'Any'
              ]
              sourceAddresses: [
               subnetSpokeDevOpsAddressSpace
              ]
            }
            {
              destinationAddresses: [
                '*'
              ]
              destinationPorts: [                
                '123'
                '12000'
              ]
              name: 'allow-ntp'
              protocols: [
                'Any'
              ]
              sourceAddresses: [
                subnetSpokeDevOpsAddressSpace
              ]
            }
          ]
        }
      }
    ]

// ------------------
//    RESOURCES
// ------------------

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.1.1' = {
  name: 'vnetHub-Deployment'
  params: {
    addressPrefixes: [vnetHubAddressSpace]
    name: resourceNames.vnetHub
    location: location
    subnets: subnets
    enableTelemetry: true
    ddosProtectionPlanResourceId: !empty(ddosProtectionPlanId) ? ddosProtectionPlanId : null
  }
}

module publicIpFWMgmt 'br/public:avm/res/network/public-ip-address:0.3.1' = {
  name: 'AZFW-Management-PIP'
  params: {
    name: 'AZFW-Management-PIP'
    location: location
    zones: zones
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard'
    skuTier: 'Regional'
    enableTelemetry: true
  }
}

module publicipbastion 'br/public:avm/res/network/public-ip-address:0.3.1' = {
  name: 'publicipbastion'
  params: {
    name: resourceNames.bastionService
    location: location
    publicIPAllocationMethod: 'Static'
    skuName: 'Standard'
    skuTier: 'Regional'
    enableTelemetry: true
  }
}

module bastionHost 'br/public:avm/res/network/bastion-host:0.1.1' = {
  name: 'bastion'
  params: {
    name: resourceNames.bastionService
    vNetId: virtualNetwork.outputs.resourceId
    bastionSubnetPublicIpResourceId: publicipbastion.outputs.resourceId
    location: location
    enableTelemetry: true
  }
}

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.3.5' = {
  name: 'laws'
  params: {
    name: resourceNames.laws
    location: location
    skuName: 'PerGB2018'
    dataRetention: 30
    tags: tags
  }
}

module azureFirewall 'br/public:avm/res/network/azure-firewall:0.1.1' = {
  name: take('afw-${deployment().name}', 64)
  params: {
    name: virtualNetwork.outputs.name
    location: location
    azureSkuTier: azureSkuTier
    virtualNetworkResourceId: virtualNetwork.outputs.resourceId
    publicIPResourceID: publicIpFWMgmt.outputs.resourceId
    managementIPResourceID: publicIpFWMgmt.outputs.resourceId
    applicationRuleCollections: applicationRules
    natRuleCollections: []
    threatIntelMode: 'Deny'
    networkRuleCollections: networkRules
    diagnosticSettings: [
      {
        name: 'customSetting'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
  }
}

// ------------------
//    OUTPUTS
// ------------------

@description('Resource name of the hub vnet')
output vnetHubName string = virtualNetwork.outputs.name

@description('Resource Id of the hub vnet')
output vnetHubId string = virtualNetwork.outputs.resourceId

@description('The private IP of the Azure firewall.')
output firewallPrivateIp string = azureFirewall.outputs.privateIp
