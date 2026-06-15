resource "azurerm_container_registry" "main" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  sku                    = var.sku
  admin_enabled          = false
  anonymous_pull_enabled = var.anonymous_pull_enabled
  tags                   = var.tags
}
