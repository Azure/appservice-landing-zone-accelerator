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
    principalId: vmJumpHostUserAssignedManagedIdentity.outputs.principalId
    resourceId: keyvault.id
    roleDefinitionId: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'  //Key Vault Secrets Officer  
  }
}

module vmJumpHostIdentityOnKeyvaultCertificateOfficer '../../../shared/bicep/role-assignments/role-assignment.bicep' = {
  name: 'vmJumpHostIdentityOnKeyvaultCertificateOfficer-Deployment'
  params: {
    principalId: vmJumpHostUserAssignedManagedIdentity.outputs.principalId
    resourceId: keyvault.id
    roleDefinitionId: 'a4417e6f-fecd-4de8-b567-7b0420556985'  //Key Vault Certificates Officer  
  }
}

module vmJumpHostIdentityOnAppConfigDataOwner '../../../shared/bicep/role-assignments/role-assignment.bicep' = if ( !empty(appConfigStoreId) ) {
  name: 'vmJumpHostIdentityOnAppConfigDataOwner-Deployment'
  params: {
    principalId: vmJumpHostUserAssignedManagedIdentity.outputs.principalId
    resourceId: appConfigStoreId
    roleDefinitionId: '5ae67dd6-50cb-40e7-96ff-dc2bfa4b606b'  //App Configuration Data Owner  
  }
}
