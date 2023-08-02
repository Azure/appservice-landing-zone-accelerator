application_name = "lzademo"
location         = "westus2"
owner            = "cloudops@contoso.com"

vm_aad_admin_username = "jinle_microsoft.com#EXT#@customersuccessunit.onmicrosoft.com"

workerPool = 3
# Toggle deployment of optional features and services for the Landing Zone
deployment_options = {
  enable_egress_lockdown     = true
  enable_diagnostic_settings = true
  deploy_bastion             = true
  deploy_vm                  = true
}
