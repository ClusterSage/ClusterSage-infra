locals {
  zone_configs = length(var.zones) > 0 ? var.zones : (
    var.enabled ? {
      (var.name) = {
        name_prefix = var.name_prefix
      }
    } : {}
  )
}

resource "azurerm_private_dns_zone" "main" {
  for_each            = local.zone_configs
  name                = each.key
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  for_each              = local.zone_configs
  name                  = "${each.value.name_prefix}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main[each.key].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
  tags                  = var.tags
}
