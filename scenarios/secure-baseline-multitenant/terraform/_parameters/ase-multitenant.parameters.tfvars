application_name = "eslztest"
environment      = "dev"
location         = "westus3"
owner            = "cloudops@contoso.com"

# entra_admin_group_object_id = "bda41c64-1493-4d8d-b4b5-7135159d4884"
# entra_admin_group_name      = "AppSvcLZA Entra SQL Admins"

## Lookup the Entra User
# vm_entra_admin_username = "my-user@contoso.com"
## Reference an existing Entra User/Group Object ID to bypass lookup
vm_entra_admin_object_id = "bda41c64-1493-4d8d-b4b5-7135159d4884" # "AppSvcLZA Entra SQL Admins"

## Optionally provide non-entra admin credentials for the VM
# vm_admin_username         = "daniem"
# vm_admin_password         = "**************"

## Toggle deployment of optional features and services for the Landing Zone
deployment_options = {
  deploy_asev3               = true
  enable_waf                 = true
  enable_egress_lockdown     = true
  enable_diagnostic_settings = true
  deploy_bastion             = true
  deploy_redis               = true
  deploy_sql_database        = true
  deploy_app_config          = true
  deploy_vm                  = false
  deploy_openai              = true
}

## OpenAI Deployment Models
oai_deployment_models = {
  "text-embedding-ada-002" = {
    name          = "text-embedding-ada-002"
    model_format  = "OpenAI"
    model_name    = "text-embedding-ada-002"
    model_version = "2"
    sku_name      = "Standard"
  }
}

## Optionally deploy a Github runner, DevOps agent, or both to the VM. 
# devops_settings = {
#   github_runner = {
#     repository_url = "https://github.com/{organization}/{repository}"
#     token          = "runner_registration_token" # See: https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28
#   }
# 
#   devops_agent = {
#     organization_url = "https://dev.azure.com/{organization}/"
#     token            = "pat_token"
#   }
# }

appsvc_options = {
  service_plan = {
    os_type  = "Windows"
    sku_name = "I1v2"

    # Optionally configure zone redundancy (requires a minimum of three workers and Premium SKU service plan) 
    # worker_count   = 3
    # zone_redundant = true
  }

  web_app = {
    application_stack = {
      current_stack  = "dotnet"
      dotnet_version = "v6.0"
    }
    slots = ["staging"]
  }
}
