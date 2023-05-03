targetScope = 'resourceGroup'

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

@description('CIDR of the subnet hosting the Bastion Service')
param subnetHubBastionAddressSpace string

@description('CIDR of the SPOKE vnet i.e. 192.168.0.0/24')
param vnetSpokeAddressSpace string

@description('CIDR of the subnet that will hold devOps agents etc ')
param subnetSpokeDevOpsAddressSpace string




//look https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-deployment#example-1
// TODO: Check if this is required or if we go with module (inline) implementation
// var privateDnsZoneNames = {
//   appConfiguration: 'privatelink.azconfig.io'
//   webApps: 'privaprivatelink.azurewebsites.net'
//   sqlDb: 'privatelink${environment().suffixes.sqlServerHostname}'
//   redis: 'privatelink.redis.cache.windows.net'
//   keyvault: 'privatelink.vaultcore.azure.net'
// }

var resourceNames = {
  bastionService: naming.bastionHost.name
  laws: take ('${naming.logAnalyticsWorkspace.name}-hub', 63)
  azFw: naming.firewall.name
  vnetHub: take('${naming.virtualNetwork.name}-hub', 80)
  subnetFirewall: 'AzureFirewallSubnet'
  subnetBastion: 'AzureBastionSubnet'
}

var subnets = [ 
  {
    name: resourceNames.subnetFirewall
    properties: {
      addressPrefix: subnetHubFirewallAddressSpace
      privateEndpointNetworkPolicies: 'Disabled'  
      // networkSecurityGroup: {
      //   id: nsgAca.outputs.nsgID
      // } 
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


module vnetHub '../../shared/bicep/network/vnet.bicep' = {
  name: 'vnetHub-Deployment'
  params: {
    location: location
    name: resourceNames.vnetHub
    subnetsInfo: subnets
    tags: tags
    vnetAddressSpace:  vnetHubAddressSpace
  }
}

module bastionSvc '../../shared/bicep/network/bastion.bicep' = {
  name: 'bastionSvc-Deployment'
  params: {
    location: location
    name: resourceNames.bastionService
    vnetId: vnetHub.outputs.vnetId
    tags: tags
    sku: 'Standard'
  }
}

module laws '../../shared/bicep/log-analytics-ws.bicep' = {
  name: 'laws-Deployment'
  params: {
    location: location
    name: resourceNames.laws

    tags: tags
  }
}

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

    
module azFw '../../shared/bicep/network/firewall.bicep' = {
  name: 'azFW-Deployment'
  params: {
    location: location
    name: resourceNames.azFw    
    vnetId: vnetHub.outputs.vnetId
    diagnosticWorkspaceId: laws.outputs.logAnalyticsWsId
    tags: tags
    applicationRuleCollections: applicationRules
    networkRuleCollections: networkRules
  }
}

// module privateDnsZoneAppConfig  '../../shared/bicep/private-dns-zone.bicep' = {
//   name: 'privateDnsZoneAppConfigDeployment'
//   params: {
//     name: privateDnsZoneNames.appConfiguration
//     virtualNetworkLinks: virtualNetworkLinks
//     tags: tags
//   }
// }

// module privateDnsKeyvault  '../../shared/bicep/private-dns-zone.bicep' = {
//   name: 'privateDnsKeyvaultDeployment'
//   params: {
//     name: privateDnsZoneNames.keyvault
//     virtualNetworkLinks: virtualNetworkLinks
//     tags: tags
//   }
// }

// module privateDnsRedis  '../../shared/bicep/private-dns-zone.bicep' = {
//   name: 'privateDnsRedisDeployment'
//   params: {
//     name: privateDnsZoneNames.redis
//     virtualNetworkLinks: virtualNetworkLinks
//     tags: tags
//   }
// }

// module privateDnsZoneSql  '../../shared/bicep/private-dns-zone.bicep' = {
//   name: 'privateDnsZoneSqlDeployment'
//   params: {
//     name: privateDnsZoneNames.sqlDb
//     virtualNetworkLinks: virtualNetworkLinks
//     tags: tags
//   }
// }

// module privateDnsWebApps  '../../shared/bicep/private-dns-zone.bicep' = {
//   name: 'privateDnsWebAppsDeployment'
//   params: {
//     name: privateDnsZoneNames.webApps
//     virtualNetworkLinks: virtualNetworkLinks
//     tags: tags
//   }
// }

@description('Resource name of the hub vnet')
output vnetHubName string = vnetHub.outputs.vnetName

@description('Resource Id of the hub vnet')
output vnetHubId string = vnetHub.outputs.vnetId

@description('The private IP of the Azure firewall.')
output firewallPrivateIp string = azFw.outputs.azFwPrivateIp
