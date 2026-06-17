resource "azurerm_cognitive_account" "main" {
  count = var.enabled ? 1 : 0

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  kind                          = "OpenAI"
  sku_name                      = var.account_sku_name
  local_auth_enabled            = var.local_auth_enabled
  public_network_access_enabled = var.public_network_access_enabled
  custom_subdomain_name         = var.custom_subdomain_name
  tags                          = var.tags
}

resource "azurerm_cognitive_deployment" "main" {
  count = var.enabled ? 1 : 0

  name                 = var.deployment_name
  cognitive_account_id = azurerm_cognitive_account.main[0].id

  model {
    format  = "OpenAI"
    name    = var.model_name
    version = var.model_version
  }

  sku {
    name     = var.deployment_sku_name
    capacity = var.deployment_capacity
  }
}

resource "azurerm_role_assignment" "backend_openai_user" {
  count = var.enabled && var.backend_managed_identity_principal_id != null ? 1 : 0

  scope                = azurerm_cognitive_account.main[0].id
  role_definition_name = var.backend_role_definition_name
  principal_id         = var.backend_managed_identity_principal_id
}

resource "azurerm_key_vault_secret" "api_key" {
  count = var.enabled && var.store_api_key_in_key_vault && var.key_vault_id != null ? 1 : 0

  name         = var.key_vault_api_key_secret_name
  value        = azurerm_cognitive_account.main[0].primary_access_key
  key_vault_id = var.key_vault_id
}
