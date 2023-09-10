module "openai" {
  source = "../../../shared/terraform-modules/openai"

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
  }

  tags = local.base_tags
}