output "profile_id" { value = azurerm_cdn_frontdoor_profile.main.id }
output "endpoint_hostname" { value = azurerm_cdn_frontdoor_endpoint.main.host_name }
output "waf_policy_id" { value = azurerm_cdn_frontdoor_firewall_policy.main.id }
output "origin_group_ids" {
  value = {
    for name, origin_group in azurerm_cdn_frontdoor_origin_group.main : name => origin_group.id
  }
}
output "origin_ids" {
  value = {
    for name, origin in azurerm_cdn_frontdoor_origin.main : name => origin.id
  }
}
output "custom_domain_ids" {
  value = {
    for name, domain in azurerm_cdn_frontdoor_custom_domain.main : name => domain.id
  }
}
output "route_ids" {
  value = {
    for name, route in azurerm_cdn_frontdoor_route.main : name => route.id
  }
}
output "custom_domain_validation_tokens" {
  value = {
    for name, domain in azurerm_cdn_frontdoor_custom_domain.main : name => domain.validation_token
  }
}
