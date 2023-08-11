application_name = "lzademo"
location         = "westus2"
owner            = "cloudops@contoso.com"

## Lookup the Azure AD User
# vm_aad_admin_username = "my-user@contoso.com"
## Reference an existing Azure AD User/Group Object ID to bypass lookup
vm_aad_admin_object_id = "bda41c64-1493-4d8d-b4b5-7135159d4884" # "AppSvcLZA Azure AD SQL Admins"


workerPool = 3
# Toggle deployment of optional features and services for the Landing Zone
deployment_options = {
  enable_egress_lockdown     = true
  enable_diagnostic_settings = true
  deploy_bastion             = true
  deploy_vm                  = true
}
