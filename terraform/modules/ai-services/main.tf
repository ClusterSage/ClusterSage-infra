resource "azurerm_cognitive_account" "document_intelligence" {
  count               = var.create_document_intelligence ? 1 : 0
  name                = var.document_intelligence_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FormRecognizer"
  sku_name            = var.document_intelligence_sku_name
  tags                = var.tags
}

resource "azurerm_cognitive_account" "openai" {
  count               = var.create_openai ? 1 : 0
  name                = var.openai_name
  location            = coalesce(var.openai_location, var.location)
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = var.openai_sku_name
  tags                = var.tags
}

resource "azurerm_cognitive_deployment" "openai" {
  count = var.create_openai && var.openai_deployment_name != "" && var.openai_model_name != "" ? 1 : 0

  name                 = var.openai_deployment_name
  cognitive_account_id = azurerm_cognitive_account.openai[0].id

  model {
    format  = "OpenAI"
    name    = var.openai_model_name
    version = var.openai_model_version
  }

  sku {
    name     = var.openai_deployment_sku_name
    capacity = var.openai_deployment_capacity
  }
}
