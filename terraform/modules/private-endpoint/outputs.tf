output "id" { value = var.enabled ? azurerm_private_endpoint.main[0].id : null }
