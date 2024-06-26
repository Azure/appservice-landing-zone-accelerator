// ------------------
//    PARAMETERS
// ------------------

@description('Required. Name of windows VM.')
@minLength(2)
@maxLength(64)
param vmWindowsJumpboxName string

@minLength(3)
@maxLength(128)
@description('Required. Name of the vmJumpHostUserAssignedManagedIdenity.')
param vmJumpHostUserAssignedManagedIdentityName string

@description('optional, default value is azureuser')
param adminUsername string

@description('mandatory, the password of the admin user')
@secure()
param adminPassword string

@description('Optional. Location for all resources.')
param location string

@description('Resource tags that we might need to add to all resources (i.e. Environment, Cost center, application name etc)')
param tags object

@description('The name of an existing keyvault, that it will be used to store secrets (connection string)' )
param keyvaultName string

@description('The name of app config store, if any' )
param appConfigStoreId string

// post deployment specific parameters  

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

@description('Mandatory. subnet resource Id where the nic will be attached to.')
param subnetId string

@description('Optional. Indicates whether IP forwarding is enabled on this network interface.')
param enableIPForwarding bool = false

@description('Optional. If the network interface is accelerated networking enabled.')
param enableAcceleratedNetworking bool = false

@description('Optional. List of DNS servers IP addresses. Use \'AzureProvidedDNS\' to switch to azure provided DNS resolution. \'AzureProvidedDNS\' value cannot be combined with other IPs, it must be the only value in dnsServers collection.')
param dnsServers array = []

@description('Optional. The network security group (NSG) to attach to the network interface.')
param networkSecurityGroupResourceId string = ''

param enableEntraJoin bool = true

@description('optional, default value is Standard_B2ms')
param vmSize string = 'Standard_B2ms'

// ------------------
//    VARIABLES
// ------------------

var entraLoginExtensionName = 'AADLoginForWindows'
var installClisValue = installClis ? '-install_clis' : ''
var installSsmsValue = installSsms ? '-install_ssms' : ''

// ------------------
//    RESOURCES
// ------------------

resource keyvault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: keyvaultName
}

module networkInterface 'br/public:avm/res/network/network-interface:0.2.4' = {
  name: 'networkInterface-Deployment'
  params: {
    name: 'networkInterface'
    location: location
    tags: tags
    enableAcceleratedNetworking: enableAcceleratedNetworking
    enableIPForwarding: enableIPForwarding
    dnsServers: !empty(dnsServers) ? dnsServers : null
    networkSecurityGroupResourceId: !empty(networkSecurityGroupResourceId) ? networkSecurityGroupResourceId : null
    ipConfigurations: [
      {
        name: 'ipconfig01'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]

  }
}

module jumpBox 'br/public:avm/res/compute/virtual-machine:0.5.1' = {
  name: 'jumpBox-Deployment'
  params: {
    name: vmWindowsJumpboxName
    location: location
    tags: tags
    adminPassword: adminPassword
    adminUsername: adminUsername
    vmSize: vmSize
    osType: 'Windows'
    imageReference: {
      publisher: 'MicrosoftWindowsDesktop'
      offer: 'Windows-11'
      sku: 'win11-22h2-pro'
      version: 'latest'
    }
    osDisk: {
      diskSizeGB: 128
      createOption: 'FromImage'
      managedDisk: {
        storageAccountType: 'Standard_LRS'
      }
    }
    nicConfigurations: [
      {
        id: networkInterface.outputs.resourceId
        properties: {
          deleteOption: 'Delete'
        }
      }
    ]
    bootDiagnostics: true
    provisionVMAgent: true
    enableAutomaticUpdates: true
    patchMode: 'AutomaticByOS'
    patchAssessmentMode: 'ImageDefault'
    zone: 0
  }
}

resource jumphostExisting 'Microsoft.Compute/virtualMachines@2023-09-01' existing = {
  name: vmWindowsJumpboxName
}

resource virtualMachineName_entraLoginExtensionName 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = if (enableEntraJoin) {
  parent: jumphostExisting
  name: entraLoginExtensionName
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: entraLoginExtensionName
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}

resource vmPostDeploymentScript 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  parent: jumphostExisting
  name: 'customScriptExtension'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/Azure/appservice-landing-zone-accelerator/main/scenarios/shared/scripts/win-devops-vm-extensions/post-deployment.ps1'
      ]      
    }    
    protectedSettings: {
      // commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File post-deployment.ps1 -install_ssms '
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File post-deployment.ps1 -github_repository "${githubRepository}" -github_token "${githubToken}" -ado_organization "${adoOrganization}" -ado_token "${adoToken}" ${installClisValue} ${installSsmsValue}'
    }
  }
}


module vmJumpHostUserAssignedManagedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.2.2' = {
  name: 'vmJumpHostUserAssignedManagedIdenity-Deployment'
  params: {
    name: vmJumpHostUserAssignedManagedIdentityName
    location: location
    tags: tags
  }
}

module vmJumpHostIdentityOnKeyvaultSecretsOfficer '../../../shared/bicep/role-assignments/role-assignment.bicep' = {
  name: 'vmJumpHostIdentityOnKeyvaultSecretsOfficer-Deployment'
  params: {
    name: 'ra-vmJumpHostIdentityOnKeyvaultSecretsOfficer'
    principalId: vmJumpHostUserAssignedManagedIdentity.outputs.principalId
    resourceId: keyvault.id
    roleDefinitionId: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'  //Key Vault Secrets Officer  
  }
}

module vmJumpHostIdentityOnKeyvaultCertificateOfficer '../../../shared/bicep/role-assignments/role-assignment.bicep' = {
  name: 'vmJumpHostIdentityOnKeyvaultCertificateOfficer-Deployment'
  params: {
    name: 'ra-vmJumpHostIdentityOnKeyvaultCertificateOfficer'
    principalId: vmJumpHostUserAssignedManagedIdentity.outputs.principalId
    resourceId: keyvault.id
    roleDefinitionId: 'a4417e6f-fecd-4de8-b567-7b0420556985'  //Key Vault Certificates Officer  
  }
}

module vmJumpHostIdentityOnAppConfigDataOwner '../../../shared/bicep/role-assignments/role-assignment.bicep' = if ( !empty(appConfigStoreId) ) {
  name: 'vmJumpHostIdentityOnAppConfigDataOwner-Deployment'
  params: {
    name: 'ra-vmJumpHostIdentityOnAppConfigDataOwner'
    principalId: vmJumpHostUserAssignedManagedIdentity.outputs.principalId
    resourceId: appConfigStoreId
    roleDefinitionId: '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b'  //App Configuration Data Owner  
  }
}
