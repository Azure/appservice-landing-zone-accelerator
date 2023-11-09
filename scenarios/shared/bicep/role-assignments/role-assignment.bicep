//from https://github.com/Azure/bicep/discussions/5805    brwilkinson

@description('The name of the RoleAssignment. Can be found by running: az role assignment list --output json')
@maxLength(64)
param name string

@description('The type of resource you wish to assign the role to. Can be found by running: az resource list --output json')
param resourceId string

@sys.description('The GUID of the RoleDefinition you wish to assign. Can be found by running: az role definition list --output json')
param roleDefinitionId string
param principalId string

@allowed([
  'ServicePrincipal'
  'Device'
  'ForeignGroup'
  'Group'
  'User'
])
@sys.description('Optional, default ServicePrincipal')
param principalType string = 'ServicePrincipal'
#disable-next-line no-unused-params
param roledescription string = '' // leave these for loggin in the portal

// // ----------------------------------------------
// // Implement own resourceId for any segment length
// var segments = split(resourceType,'/')
// var items = split(resourceName,'/')
// var last = length(items)
// var segment = [for (item, index) in range(1,last) : item == 1 ? '${segments[0]}/${segments[item]}/${items[index]}/' : item != last ? '${segments[item]}/${items[index]}/' : '${segments[item]}/${items[index]}' ]
// var resourceid =  replace(replace(replace(string(string(segment)), '","', ''), '["', ''), '"]', '') // currently no join() method
// // ----------------------------------------------
#disable-next-line no-deployments-resources
resource resourceRoleAssignment 'Microsoft.Resources/deployments@2021-04-01' = {
    name: name // take('RA-${principalId}-${roleDefinitionId}-${last(split(resourceId,'/'))}',64)
    properties: {
        mode: 'Incremental'
        expressionEvaluationOptions: {
            scope: 'Outer'
        }
        template: json(loadTextContent('./generic-role-assignment.json'))
        parameters: {
            scope: {
                value: resourceId
            }
            name: {
                value: guid(principalId, roleDefinitionId, resourceId)
            }
            roleDefinitionId: {
                value: roleDefinitionId
            }
            principalId: {
                value: principalId
            }
            principalType: {
                value: principalType
            }
        }
    }
}

output resourceid string = resourceId
output roleAssignmentId string = resourceRoleAssignment.properties.outputs.roleAssignmentId.value
