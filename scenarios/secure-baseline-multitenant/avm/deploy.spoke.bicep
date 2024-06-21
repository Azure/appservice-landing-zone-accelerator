targetScope = 'resourceGroup'

// reference to the BICEP naming module
param naming object


@description('Azure region where the resources will be deployed in')
param location string = resourceGroup().location

@description('Optional, default is false. Set to true if you want to deploy ASE v3 instead of Multitenant App Service Plan.')
param deployAseV3 bool = false

@description('CIDR of the SPOKE vnet i.e. 192.168.0.0/24')
param vnetSpokeAddressSpace string

@description('CIDR of the subnet that will hold the app services plan')
param subnetSpokeAppSvcAddressSpace string

@description('CIDR of the subnet that will hold devOps agents etc ')
param subnetSpokeDevOpsAddressSpace string

@description('CIDR of the subnet that will hold the private endpoints of the supporting services')
param subnetSpokePrivateEndpointAddressSpace string

@description('Internal IP of the Azure firewall deployed in Hub. Used for creating UDR to route all vnet egress traffic through Firewall. If empty no UDR')
param firewallInternalIp string = ''

@description('if empty, private dns zone will be deployed in the current RG scope')
param vnetHubResourceId string = ''

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('Create (or not) a UDR for the App Service Subnet, to route all egress traffic through Hub Azure Firewall')
param enableEgressLockdown bool

@description('Deploy (or not) a redis cache')
param deployRedis bool

@description('Deploy (or not) an Azure SQL with default database ')
param deployAzureSql bool

@description('Deploy (or not) an Azure app configuration')
param deployAppConfig bool

@description('Deploy (or not) an Azure virtual machine (to be used as jumphost)')
param deployJumpHost bool

@description('Deploy (or not) an Azure OpenAI account. ATTENTION: At the time of writing this, OpenAI is in preview and only available in limited regions: look here: https://learn.microsoft.com/azure/ai-services/openai/chatgpt-quickstart#prerequisites')
param deployOpenAi bool

@description('Deploy (or not) a model on the openAI Account. This is used only as a sample to show how to deploy a model on the OpenAI account.')
param deployOpenAiGptModel bool = false

// post deployment specific parameters for the jumpBox
@description('The URL of the Github repository to use for the Github Actions Runner. This parameter is optional. If not provided, the Github Actions Runner will not be installed. If this parameter is provided, then github_token must also be provided.')
param githubRepository string = '' 

@description('The token to use for the Github Actions Runner. This parameter is optional. If not provided, the Github Actions Runner will not be installed. If this parameter is provided, then github_repository must also be provided.')
param githubToken string = '' 

@description('The URL of the Azure DevOps organization to use for the Azure DevOps Agent. This parameter is optional. If not provided, the Github Azure DevOps will not be installed. If this parameter is provided, then ado_token must also be provided.')
param adoOrganization string = '' 

@description('The PAT token to use for the Azure DevOps Agent. This parameter is optional. If not provided, the Github Azure DevOps will not be installed. If this parameter is provided, then ado_organization must also be provided.')
param adoToken string = '' 

@description('A switch to indicate whether or not to install the Azure CLI, AZD CLI and git. This parameter is optional. If not provided, the Azure CLI, AZD CLI and git will not be installed')
param installClis bool = false

@description('A switch to indicate whether or not to install Sql Server Management Studio (SSMS). This parameter is optional. If not provided, SSMS will not be installed.')
param installSsms bool = false

@description('Optional S1 is default. Defines the name, tier, size, family and capacity of the App Service Plan. Plans ending to _AZ, are deploying at least three instances in three Availability Zones. EP* is only for functions')
@allowed([ 'S1', 'S2', 'S3', 'P1V3', 'P2V3', 'P3V3', 'P1V3_AZ', 'P2V3_AZ', 'P3V3_AZ', 'EP1', 'EP2', 'EP3', 'ASE_I1V2_AZ', 'ASE_I2V2_AZ', 'ASE_I3V2_AZ', 'ASE_I1V2', 'ASE_I2V2', 'ASE_I3V2' ])
param webAppPlanSku string

@description('Kind of server OS of the App Service Plan')
@allowed([ 'Windows', 'Linux'])
param webAppBaseOs string

@description('optional, default value is azureuser')
param adminUsername string

@description('mandatory, the password of the admin user')
@secure()
param adminPassword string

@description('Conditional. The Microsoft Entra ID administrator authentication. Required if no `sqlAdminLogin` & `sqlAdminPassword` is provided.')
param sqlServerAdministrators object = {}

@description('Conditional. If sqlServerAdministrators is given, this is not required')
param sqlAdminLogin string = ''

@description('Conditional. If sqlServerAdministrators is given, this is not required')
@secure()
param sqlAdminPassword string = ''

@description('set to true if you want to auto approve the Private Endpoint of the AFD')
param autoApproveAfdPrivateEndpoint bool = true

var resourceNames = {
  storageAccount: naming.storageAccount.nameUnique
  vnetSpoke: take('${naming.virtualNetwork.name}-spoke', 80)
  snetAppSvc: 'snet-appSvc-${naming.virtualNetwork.name}-spoke'
  snetDevOps: 'snet-devOps-${naming.virtualNetwork.name}-spoke'
  snetPe: 'snet-pe-${naming.virtualNetwork.name}-spoke'
  pepNsg: take('${naming.networkSecurityGroup.name}-pep', 80)
  aseNsg: take('${naming.networkSecurityGroup.name}-ase', 80)
  appSvcUserAssignedManagedIdentity: take('${naming.userAssignedManagedIdentity.name}-appSvc', 128)
  vmJumpHostUserAssignedManagedIdentity: take('${naming.userAssignedManagedIdentity.name}-vmJumpHost', 128)
  keyvault: naming.keyVault.nameUnique
  logAnalyticsWs: naming.logAnalyticsWorkspace.name
  appInsights: naming.applicationInsights.name
  aseName: naming.appServiceEnvironment.nameUnique
  aspName: naming.appServicePlan.name
  webApp: naming.appService.nameUnique
  vmWindowsJumpbox: take('${naming.windowsVirtualMachine.name}-win-jumpbox', 64)
  redisCache: naming.redisCache.nameUnique
  sqlServer: naming.mssqlServer.nameUnique
  sqlDb:'sample-db'
  appConfig: take ('${naming.appConfiguration.nameUnique}-${ take( uniqueString(resourceGroup().id, subscription().id), 6) }', 50)
  frontDoor: naming.frontDoor.name
  frontDoorEndPoint: 'webAppLza-${ take( uniqueString(resourceGroup().id, subscription().id), 6) }'  //globally unique
  frontDoorWaf: naming.frontDoorFirewallPolicy.name
  routeTable: naming.routeTable.name
  routeEgressLockdown: '${naming.route.name}-egress-lockdown'
  idAfdApprovePeAutoApprover: take('${naming.userAssignedManagedIdentity.name}-AfdApprovePe', 128)
  openAiAccount: naming.cognitiveAccount.nameUnique
  openAiDeployment: naming.openAiDeployment.name
}

var udrRoutes = [
                  {
                    name: 'defaultEgressLockdown'
                    properties: {
                      addressPrefix: '0.0.0.0/0'
                      nextHopIpAddress: firewallInternalIp 
                      nextHopType: 'VirtualAppliance'
                    }
                  }
                ]

var subnets = [ 
  {
    name: resourceNames.snetAppSvc
    properties: {
      addressPrefix: subnetSpokeAppSvcAddressSpace
      privateEndpointNetworkPolicies: !(deployAseV3) ? 'Enabled' : 'Disabled'  
      delegations: [
        {
          name: 'delegation'
          properties: {
            serviceName: !(deployAseV3) ? 'Microsoft.Web/serverfarms' : 'Microsoft.Web/hostingEnvironments'
          }
        }
      ]
      networkSecurityGroup: {
        id: !(deployAseV3) ? networkSecurityGroupPEP.outputs.resourceId : networkSecurityGroupASE.outputs.resourceId
      } 
      routeTable: !empty(firewallInternalIp) && (enableEgressLockdown) ? {
        id: routeTable.outputs.resourceId 
      } : null
    } 
  }
  {
    name: resourceNames.snetDevOps
    properties: {
      addressPrefix: subnetSpokeDevOpsAddressSpace
      privateEndpointNetworkPolicies: 'Enabled'   
      networkSecurityGroup: {
        id: networkSecurityGroupPEP.outputs.resourceId
      } 
    }    
  }
  {
    name: resourceNames.snetPe
    properties: {
      addressPrefix: subnetSpokePrivateEndpointAddressSpace
      privateEndpointNetworkPolicies: 'Disabled'  
      networkSecurityGroup: {
        id: networkSecurityGroupPEP.outputs.resourceId
      }  
    }    
  }
]

var virtualNetworkLinks = [
  {
    vnetName: virtualNetwork.outputs.name
    vnetId: virtualNetwork.outputs.resourceId
    registrationEnabled: false
  }
  {
    vnetName: vnetHub.name
    vnetId: vnetHub.id
    registrationEnabled: false
  }
]

var vnetHubSplitTokens = !empty(vnetHubResourceId) ? split(vnetHubResourceId, '/') : array('')

resource vnetHub  'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: vnetHubSplitTokens[8]
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.1.1' = {
  name: 'vnetSpoke-Deployment'
  params: {
    addressPrefixes: [vnetSpokeAddressSpace]
    name: resourceNames.vnetSpoke
    location: location
    subnets: subnets
    tags: tags
  }
}

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.3.5' = {
  name: 'laws'
  params: {
    name: resourceNames.logAnalyticsWs
    location: location
    skuName: 'PerGB2018'
    dataRetention: 30
    tags: tags
  }
}

@description('NSG Rules for the private enpoint subnet.')
module networkSecurityGroupPEP 'br/public:avm/res/network/network-security-group:0.1.1' = {
  name: take('nsgPep-${deployment().name}', 64)
  params: {
    name: resourceNames.pepNsg
    tags: tags
    diagnosticSettings: [{workspaceResourceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId}]
    location: location
    securityRules: []
  }
}

@description('NSG Rules for the ASE subnet.')
module networkSecurityGroupASE 'br/public:avm/res/network/network-security-group:0.1.1' = {
  name: take('nsgAse-${deployment().name}', 64)
  params: {
    name: resourceNames.aseNsg
    tags: tags
    diagnosticSettings: [{workspaceResourceId: logAnalyticsWorkspace.outputs.logAnalyticsWorkspaceId}]
    location: location
    securityRules: [
      {
        name: 'SSL_WEB_443'
        properties: {
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
          priority: 100
        }        
      }
    ]
  }
}

module routeTable 'br/public:avm/res/network/route-table:0.2.2' = {
  name: resourceNames.routeTable
  params: {
    name: resourceNames.routeTable
    location: location
    tags: tags
    routes: udrRoutes
  }
}

module keyVault 'br/public:avm/res/key-vault/vault:0.6.2' = {
  name: take('${resourceNames.keyvault}-keyvaultModule-Deployment', 64)
  params: {
    name: resourceNames.keyvault
    location: location
    tags: tags
  }
}
var keyvaultDnsZoneName = 'privatelink.vaultcore.azure.net'

module keyVaultDnsZone 'br/public:avm/res/network/private-dns-zone:0.3.0' = {
  scope: resourceGroup(vnetHubSplitTokens[2], vnetHubSplitTokens[4])
  name: take('${resourceNames.keyvault}-dnsZoneModule-Deployment', 64)
  params: {
    name: keyvaultDnsZoneName
    location: location
    tags: tags
  }
}
