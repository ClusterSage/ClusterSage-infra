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
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = var.openai_sku_name
  tags                = var.tags
}
