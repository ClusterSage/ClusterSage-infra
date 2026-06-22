resource "azurerm_postgresql_flexible_server" "main" {
  name                          = coalesce(var.server_name, "pg-${var.name_prefix}")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "16"
  administrator_login           = var.administrator_login
  administrator_password        = var.administrator_password
  storage_mb                    = var.storage_mb
  sku_name                      = var.sku_name
  backup_retention_days         = 7
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  lifecycle {
    ignore_changes = [
      administrator_password,
      zone,
    ]
  }
}

resource "azurerm_postgresql_flexible_server" "replica" {
  count = var.create_replica ? 1 : 0

  name                          = coalesce(var.replica_name, "${coalesce(var.server_name, "pg-${var.name_prefix}")}-dr")
  resource_group_name           = var.resource_group_name
  location                      = coalesce(var.replica_location, var.location)
  version                       = "16"
  administrator_login           = var.administrator_login
  administrator_password        = var.administrator_password
  storage_mb                    = var.storage_mb
  sku_name                      = var.sku_name
  create_mode                   = "Replica"
  source_server_id              = azurerm_postgresql_flexible_server.main.id
  public_network_access_enabled = coalesce(var.replica_public_network_access_enabled, var.public_network_access_enabled)
  tags                          = var.tags

  lifecycle {
    ignore_changes = [
      administrator_password,
      zone,
    ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  count = var.create_azure_services_firewall_rule ? 1 : 0

  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
