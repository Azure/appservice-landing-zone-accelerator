# Not broken into its own module as it is only used in this scenario
resource "azurecaf_name" "caf_name_asev3" {
  count = var.deployment_options.deploy_asev3 ? 1 : 0

  name          = var.application_name
  resource_type = "azurerm_app_service_environment"
  prefixes      = local.global_settings.prefixes
  suffixes      = local.global_settings.suffixes
  random_length = local.global_settings.random_length
  clean_input   = true
  passthrough   = local.global_settings.passthrough

  use_slug = local.global_settings.use_slug
}

resource "azurerm_app_service_environment_v3" "this" {
  count = var.deployment_options.deploy_asev3 ? 1 : 0

  name                = azurecaf_name.caf_name_asev3.0.result
  resource_group_name = azurerm_resource_group.spoke.name

  # a /24 or larger CIDR is required. Once associated with an ASE, this size cannot be changed.
  subnet_id = module.network.subnets["hostingEnvironments"].id

  # Possible values are None (for an External VIP Type), and "Web, Publishing" (for an Internal VIP Type).
  internal_load_balancing_mode = "Web, Publishing"

  # Required for Private DNS and Endpoint configs
  allow_new_private_endpoint_connections = true

  # You can only set either dedicated_host_count or zone_redundant but not both. 
  # Changing this forces a new resource to be created.
  # dedicated_host_count = 2

  # Changing this forces a new resource to be created.
  zone_redundant = var.zone_redundant


  cluster_setting {
    name  = "DisableTls1.0"
    value = "1"
  }

  ## Caution: Enabling internal encryption will add hours to your deployment time
  # cluster_setting {
  #   name  = "InternalEncryption"
  #   value = "true"
  # }

  cluster_setting {
    name  = "FrontEndSSLCipherSuiteOrder"
    value = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  }

  tags = local.base_tags
}