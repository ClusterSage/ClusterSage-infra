output "document_intelligence_endpoint" {
  value = var.create_document_intelligence ? azurerm_cognitive_account.document_intelligence[0].endpoint : null
}

output "openai_endpoint" {
  value = var.create_openai ? azurerm_cognitive_account.openai[0].endpoint : null
}
