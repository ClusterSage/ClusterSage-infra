output "id" {
  value = var.enabled ? azurerm_cognitive_account.main[0].id : null
}

output "name" {
  value = var.enabled ? azurerm_cognitive_account.main[0].name : null
}

output "endpoint" {
  value = var.enabled ? azurerm_cognitive_account.main[0].endpoint : null
}

output "deployment_name" {
  value = var.enabled ? azurerm_cognitive_deployment.main[0].name : null
}

output "deployment_id" {
  value = var.enabled ? azurerm_cognitive_deployment.main[0].id : null
}

output "api_key_secret_name" {
  value = var.enabled && var.store_api_key_in_key_vault ? var.key_vault_api_key_secret_name : null
}

output "primary_access_key" {
  value     = var.enabled && var.store_api_key_in_key_vault ? azurerm_cognitive_account.main[0].primary_access_key : null
  sensitive = true
}
