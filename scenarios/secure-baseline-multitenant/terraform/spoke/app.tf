# Spoke application deployment
# ------
# - App Service
#   - 
locals {
  sql_connstring   = length(module.sql_database) > 0 ? module.sql_database[0].sql_db_connection_string : "SQL_NOT_PROVISIONED"
  redis_connstring = length(module.redis_cache) > 0 ? module.redis_cache[0].redis_connection_string : "REDIS_NOT_PROVISIONED"

  # If isolated SKU (using App Service Environment) then do not enable vnet integration
  is_isolated_sku = can(regex("(?i)^I.*v2$", var.appsvc_options.service_plan.sku_name))
}

# Deploy the App Service
module "app_service" {
  source = "../../../shared/terraform-modules/app-service"

  global_settings            = local.global_settings
  resource_group             = azurerm_resource_group.spoke.name
  application_name           = var.application_name
  location                   = var.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  enable_diagnostic_settings = var.deployment_options.enable_diagnostic_settings

  # If isolated SKU (using App Service Environment) then do not enable vnet integration
  appsvc_subnet_id           = local.is_isolated_sku == true ? null : module.network.subnets["serverFarm"].id
  frontend_subnet_id         = module.network.subnets["ingress"].id
  service_plan_options       = var.appsvc_options.service_plan
  app_service_environment_id = var.deployment_options.deploy_asev3 ? azurerm_app_service_environment_v3.this[0].id : null
  identity = {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.reader.id
    ]
  }

  webapp_options = {
    slots             = var.appsvc_options.web_app.slots
    application_stack = var.appsvc_options.web_app.application_stack
  }

  private_dns_zone = local.provisioned_dns_zones["privatelink.azurewebsites.net"]

  depends_on = [
    module.network,
    module.user_defined_routes,
    module.private_dns_zones
  ]

  tags = local.base_tags
}

module "key_vault" {
  source = "../../../shared/terraform-modules/key-vault"

  resource_group         = azurerm_resource_group.spoke.name
  application_name       = var.application_name
  environment            = var.environment
  location               = var.location
  tenant_id              = var.tenant_id
  unique_id              = random_integer.unique_id.result
  sku_name               = "standard"
  private_link_subnet_id = module.network.subnets["privateLink"].id
  global_settings        = local.global_settings
  tags                   = local.base_tags
  secret_reader_identities = [
    azurerm_user_assigned_identity.reader.principal_id
  ]

  secret_officer_identities = [
    azurerm_user_assigned_identity.contributor.principal_id
  ]
  private_dns_zone = local.provisioned_dns_zones["privatelink.vaultcore.azure.net"]
}


module "sql_database" {
  count = var.deployment_options.deploy_sql_database ? 1 : 0

  source = "../../../shared/terraform-modules/sql-database"

  resource_group         = azurerm_resource_group.spoke.name
  application_name       = var.application_name
  environment            = var.environment
  location               = var.location
  unique_id              = random_integer.unique_id.result
  tenant_id              = var.tenant_id
  private_link_subnet_id = module.network.subnets["privateLink"].id
  global_settings        = local.global_settings
  tags                   = local.base_tags
  sql_databases          = var.sql_databases
  key_vault_id           = module.key_vault.vault_id

  private_dns_zone = local.provisioned_dns_zones["privatelink.database.windows.net"]
}

module "app_configuration" {
  count = var.deployment_options.deploy_app_config ? 1 : 0

  source = "../../../shared/terraform-modules/app-configuration"

  resource_group         = azurerm_resource_group.spoke.name
  application_name       = var.application_name
  environment            = var.environment
  location               = var.location
  unique_id              = random_integer.unique_id.result
  tenant_id              = var.tenant_id
  private_link_subnet_id = module.network.subnets["privateLink"].id
  global_settings        = local.global_settings
  tags                   = local.base_tags
  data_reader_identities = [
    azurerm_user_assigned_identity.reader.principal_id
  ]

  data_owner_identities = [
    azurerm_user_assigned_identity.contributor.principal_id
  ]

  private_dns_zone = local.provisioned_dns_zones["privatelink.azconfig.io"]
}

module "redis_cache" {
  count = var.deployment_options.deploy_redis ? 1 : 0

  source = "../../../shared/terraform-modules/redis"

  resource_group         = azurerm_resource_group.spoke.name
  application_name       = var.application_name
  environment            = var.environment
  location               = var.location
  unique_id              = random_integer.unique_id.result
  sku_name               = "Standard"
  private_link_subnet_id = module.network.subnets["privateLink"].id
  global_settings        = local.global_settings
  tags                   = local.base_tags

  private_dns_zone = local.provisioned_dns_zones["privatelink.redis.cache.windows.net"]
}
