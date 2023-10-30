resource "azurecaf_name" "caf_name_oai" {
  name          = var.application_name
  resource_type = "azurerm_cognitive_account"
  prefixes      = var.global_settings.prefixes
  suffixes      = var.global_settings.suffixes
  random_length = var.global_settings.random_length
  clean_input   = true
  passthrough   = var.global_settings.passthrough

  use_slug = var.global_settings.use_slug
}


resource "azurerm_cognitive_account" "this" {
  kind                               = "OpenAI"
  location                           = var.location
  name                               = azurecaf_name.caf_name_oai.result
  resource_group_name                = var.resource_group_name
  sku_name                           = var.sku_name
  custom_subdomain_name              = coalesce(var.custom_subdomain_name, azurecaf_name.caf_name_oai.result)
  dynamic_throttling_enabled         = var.dynamic_throttling_enabled
  fqdns                              = var.fqdns
  local_auth_enabled                 = var.local_auth_enabled
  outbound_network_access_restricted = var.outbound_network_access_restricted
  public_network_access_enabled      = var.public_network_access_enabled

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [var.customer_managed_key] : []
    content {
      key_vault_key_id   = customer_managed_key.value.key_vault_key_id
      identity_client_id = customer_managed_key.value.identity_client_id
    }
  }
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "network_acls" {
    for_each = var.network_acls != null ? var.network_acls : []
    content {
      default_action = network_acls.value.default_action
      ip_rules       = lookup(network_acls.value, "ip_rules", null)

      dynamic "virtual_network_rules" {
        for_each = lookup(network_acls.value, "virtual_network_rules", [])
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = virtual_network_rules.value.ignore_missing_vnet_service_endpoint
        }
      }
    }
  }

  dynamic "storage" {
    for_each = var.storage
    content {
      storage_account_id = storage.value.storage_account_id
      identity_client_id = storage.value.identity_client_id
    }
  }

  tags = local.tags
}

resource "azurerm_cognitive_deployment" "this" {
  for_each = var.deployment

  cognitive_account_id = azurerm_cognitive_account.this.id
  name                 = each.value.name
  rai_policy_name      = each.value.rai_policy_name

  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }
  scale {
    type = each.value.scale_type
  }
}

