output "id" { value = azurerm_postgresql_flexible_server.main.id }
output "fqdn" { value = azurerm_postgresql_flexible_server.main.fqdn }
output "database_name" { value = azurerm_postgresql_flexible_server_database.main.name }
output "replica_id" { value = var.create_replica ? azurerm_postgresql_flexible_server.replica[0].id : null }
output "replica_fqdn" { value = var.create_replica ? azurerm_postgresql_flexible_server.replica[0].fqdn : null }
