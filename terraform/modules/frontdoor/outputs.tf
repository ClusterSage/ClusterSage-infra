output "profile_id" { value = azurerm_cdn_frontdoor_profile.main.id }
output "endpoint_hostname" { value = azurerm_cdn_frontdoor_endpoint.main.host_name }
output "waf_policy_id" { value = azurerm_cdn_frontdoor_firewall_policy.main.id }
output "custom_domain_validation_tokens" {
  value = {
    for name, domain in azurerm_cdn_frontdoor_custom_domain.main : name => domain.validation_token
  }
}
