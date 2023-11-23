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

@description('the subnet ID where the  VM will be attached to')
param subnetDevOpsId string

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

resource keyvault 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: keyvaultName
}

module vmWindows '../../../shared/bicep/compute/jumphost-win11.bicep' = {
  name: 'vmWindows-Deployment'
  params: {
    name:  vmWindowsJumpboxName 
    location: location
    tags: tags
    adminPassword: adminPassword
    adminUsername: adminUsername
    subnetId: subnetDevOpsId
    enableAzureAdJoin: true
    userAssignedIdentities: {
      '${vmJumpHostUserAssignedManagedIdentity.outputs.id}': {}
    }
    githubRepository: githubRepository
    githubToken: githubToken
    adoOrganization: adoOrganization
    adoToken: adoToken
    installClis: installClis
    installSsms: installSsms 
    installJava: installJava
    installPython: installPython
    installNode: installNode
    installPwsh: installPwsh
  }
}

module vmJumpHostUserAssignedManagedIdentity '../../../shared/bicep/managed-identity.bicep' = {
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
