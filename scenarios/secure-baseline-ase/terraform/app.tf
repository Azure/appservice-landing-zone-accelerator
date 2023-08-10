module "app_service" {
  source = "../../shared/terraform-modules/app-service"

  global_settings  = local.global_settings
  resource_group   = azurerm_resource_group.ase.name
  application_name = var.application_name
  # environment                = var.environment
  location = var.location
  # unique_id                  = random_integer.unique_id.result
  enable_diagnostic_settings = var.deployment_options.enable_diagnostic_settings

  # appsvc_subnet_id     = local.spokeVNet.subnets["hostingEnvironment"].id
  # frontend_subnet_id   = module.network.subnets[index(module.network.subnets.*.name, "ingress")].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  service_plan_options = {
    app_service_environment_id = local.ase.id
    os_type                    = "Windows"
    sku_name                   = var.workerPool == 1 ? "I1" : "I${var.workerPool}v2"
    worker_count               = var.numberOfWorkers
    zone_redundant             = true
  }

  deploy_web_app = false

  private_dns_zone = local.private_dns_zone

  tags = local.base_tags
}
