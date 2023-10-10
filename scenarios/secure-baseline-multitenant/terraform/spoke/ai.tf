module "openai" {
  count = var.deployment_options.deploy_openai ? 1 : 0

  source = "../../../shared/terraform-modules/cognitive-services/openai"

  global_settings     = local.global_settings
  resource_group_name = azurerm_resource_group.spoke.name
  location            = azurerm_resource_group.spoke.location

  deployment = {
    "text-embedding-ada-002" = {
      name          = "text-embedding-ada-002"
      model_format  = "OpenAI"
      model_name    = "text-embedding-ada-002"
      model_version = "2"
      scale_type    = "Standard"
    }
    "gpt-35-turbo" = {
      name          = "gpt-35-turbo"
      model_format  = "OpenAI"
      model_name    = "gpt-35-turbo"
      model_version = "0613"
      scale_type    = "Standard"
    }
  }

  pe_private_link_subnet_id = module.network.subnets["privateLink"].id
  private_dns_zone          = local.provisioned_dns_zones["privatelink.openai.azure.com"]

  network_acls = [
    {
      default_action = "Deny"
      virtual_network_rules = [
        {
          subnet_id                            = module.network.subnets["serverFarm"].id
          ignore_missing_vnet_service_endpoint = true
        },
        {
          subnet_id                            = module.network.subnets["ingress"].id
          ignore_missing_vnet_service_endpoint = true
        },
        {
          subnet_id                            = module.network.subnets["devops"].id
          ignore_missing_vnet_service_endpoint = true
        },
        {
          subnet_id                            = module.network.subnets["privateLink"].id
          ignore_missing_vnet_service_endpoint = true
        }
      ]
    }
  ]

  tags = local.base_tags
}
