application_name = "eslz2"
environment      = "prod"
location         = "westus2"
# location_short   = "wus3"
owner = "cloudops@contoso.com"

# Toggle deployment of optional features and services for the Landing Zone
deployment_options = {
  enable_waf                 = true
  enable_egress_lockdown     = true
  enable_diagnostic_settings = true
  deploy_bastion             = true
  deploy_redis               = true
  deploy_sql_database        = true
  deploy_app_config          = true
  deploy_vm                  = true
}
