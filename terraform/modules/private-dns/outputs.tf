output "id" { value = var.enabled ? azurerm_private_dns_zone.main[0].id : null }
