targetScope = 'resourceGroup'
// ------------------
//    PARAMETERS
// ------------------

@description('The location where the resources will be created.')
param location string

@description('The name of the azure firewall to create.')
param firewallName string

@description('The Name of the virtual network in which afw is created.')
param afwVNetName string

@description('The log analytics workspace id to which the azure firewall will send logs.')
param logAnalyticsWorkspaceId string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('CIDR of the subnet that will hold devOps agents etc ')
param subnetSpokeDevOpsAddressSpace string

@description('CIDR of the HUB vnet i.e. 192.168.0.0/24')
param vnetHubAddressSpace string

@description('CIDR of the SPOKE vnet i.e. 192.168.0.0/24')
param vnetSpokeAddressSpace string

// ------------------
//    Variables
// ------------------

@description('Application Rules for the Firewall')
var applicationRules =  [
      {
        name: 'Azure-Monitor-FQDNs'
        properties: {
          action: {
            type: 'Allow'
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
                  port: 443
                  protocolType: 'Https'
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
                  port: 443
                  protocolType: 'Https'
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
            type: 'Allow'
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
                  port: 443
                  protocolType: 'Https'
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
                  port: 443
                  protocolType: 'Https'
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
            type: 'Allow'
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
                  port: 443
                  protocolType: 'Https'
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
                  port: 443
                  protocolType: 'Https'
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
                  port: 80
                  protocolType: 'Http'
                }
                 {
                  port: 443
                  protocolType: 'Https'
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
            type: 'Allow'
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


resource hubVnet 'Microsoft.Network/virtualNetworks@2022-11-01' existing = {
  name: afwVNetName
}

@description('The azure firewall deployment.')
module afw 'br/public:avm/res/network/azure-firewall:0.3.0' = {
  name: 'afw-deployment'
  params: {
    tags: tags
    location: location
    name: firewallName
    azureSkuTier: 'Basic'
    virtualNetworkResourceId: hubVnet.id
    additionalPublicIpConfigurations: []
    applicationRuleCollections: applicationRules
    networkRuleCollections: networkRules
    natRuleCollections: []
    threatIntelMode: 'Deny'
    diagnosticSettings: [
      {
        name: 'customSetting'
        workspaceResourceId: logAnalyticsWorkspaceId
      }
    ]    
  }
}


// ------------------
//    OUTPUTS
// ------------------
output afwPrivateIp string = afw.outputs.privateIp
output afwId string = afw.outputs.resourceId
