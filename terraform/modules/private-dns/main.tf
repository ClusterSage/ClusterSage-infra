resource "azurerm_private_dns_zone" "main" {
  count               = var.enabled ? 1 : 0
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  count                 = var.enabled ? 1 : 0
  name                  = "${var.name_prefix}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main[0].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
  tags                  = var.tags
}
