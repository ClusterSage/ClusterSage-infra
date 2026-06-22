output "id" {
  value = length(azurerm_private_dns_zone.main) > 0 ? values(azurerm_private_dns_zone.main)[0].id : null
}

output "ids" {
  value = { for name, zone in azurerm_private_dns_zone.main : name => zone.id }
}
