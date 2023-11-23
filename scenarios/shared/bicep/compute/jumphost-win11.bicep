// ================ //
// Parameters       //
// ================ //

@description('Name of the resource Virtual Network (The name must begin with a letter or number, end with a letter, number or underscore, and may contain only letters, numbers, underscores, periods, or hyphens)')
@minLength(2)
@maxLength(64)
param name string

@description('Name of the windows PC. Optional, by default gets automatically constructed by the resource name. Use it to give more meaningful names, or avoid conflicts')
@maxLength(15)
param computerWindowsName string = ''

@description('Azure Region where the resource will be deployed in')
param location string

@description('key-value pairs as tags, to identify the resource')
param tags object

@description('The subnet where the VM will be attached to')
param subnetId string

@description('optional, default value is azureuser')
param adminUsername string = 'azureuser'

@description('mandatory, the password of the admin user')
@secure()
param adminPassword string

param enableAzureAdJoin bool = true

@description('optional, default value is Standard_B2ms')
param vmSize string = 'Standard_B2ms'

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

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

@description('A switch to indicate whether or not to install the Java tools.Maven is included. This parameter is optional. If not provided, the Java tools will not be installed')
param installJava bool = false

@description('A switch to indicate whether or not to install the Python tools. This parameter is optional. If not provided, the Python tools will not be installed')
param installPython bool = false

@description('A switch to indicate whether or not to install the Node tools. This parameter is optional. If not provided, the Node tools will not be installed')
param installNode bool = false

@description('A switch to indicate whether or not to install the Power Shell 6+ tools. This parameter is optional. If not provided, the Power Shell 6+ tools will not be installed')
param installPwsh bool = false

@description('A switch to indicate whether or not to install Sql Server Management Studio (SSMS). This parameter is optional. If not provided, SSMS will not be installed.')
param installSsms bool = false


// =========== //
// Variables   //
// =========== //

var aadLoginExtensionName = 'AADLoginForWindows'

var vmNameMaxLength = 64
var vmName = length(name) > vmNameMaxLength ? substring(name, 0, vmNameMaxLength) : name

var computerNameLength = 15
var computerNameValid = replace( replace(name, '-', ''), '_', '')
var computerName = length(computerNameValid) > computerNameLength ? substring(computerNameValid, 0, computerNameLength) : computerNameValid

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null


// ================ //
// Resources        //
// ================ //

module jumphostNic '../network/nic.private.dynamic.bicep' = {
  name: 'jumphostNicDeployment'
  params: {
    name: 'nic-${vmName}'
    subnetId: subnetId
    location: location
    tags: tags
  }
}

resource jumphost 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  tags: tags
  identity: identity
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-11'
        sku: 'win11-22h2-pro'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: empty(computerWindowsName) ? computerName : computerWindowsName
      adminUsername: adminUsername
      adminPassword: adminPassword      
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
        enableVMAgentPlatformUpdates: true
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: jumphostNic.outputs.nicId
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource virtualMachineName_aadLoginExtensionName 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = if (enableAzureAdJoin) {
  parent: jumphost
  name: aadLoginExtensionName
  location: location
  properties: {
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: aadLoginExtensionName
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}


var installClisValue = installClis   ? '-install_clis' : ''
var installSsmsValue = installSsms   ? '-install_ssms' : ''
var installJavaValue = installSsms   ? '-install_java_tools' : ''
var installPythonValue = installSsms ? '-install_python_tools' : ''
var installNodeValue = installSsms   ? '-install_node_tools' : ''
var installPwshValue = installSsms   ? '-install_pwsh_tools' : ''

resource vmPostDeploymentScript 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = {
  parent: jumphost
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
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File post-deployment.ps1 -github_repository "${githubRepository}" -github_token "${githubToken}" -ado_organization "${adoOrganization}" -ado_token "${adoToken}" ${installClisValue} ${installSsmsValue} ${installJavaValue} ${installPythonValue} ${installNodeValue} ${installPwshValue}'
    }
  }
}
