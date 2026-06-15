resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "afd-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "fde-${var.name_prefix}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  enabled                  = true
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_firewall_policy" "main" {
  name                = substr(replace("waf-${var.name_prefix}", "-", ""), 0, 128)
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  enabled             = true
  mode                = var.waf_mode
  tags                = var.tags

  managed_rule {
    type    = "DefaultRuleSet"
    version = "1.0"
    action  = "Block"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.1"
    action  = "Block"
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "main" {
  for_each                 = var.origin_groups
  name                     = each.key
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  session_affinity_enabled = false

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 50
  }

  health_probe {
    interval_in_seconds = 100
    path                = each.value.health_probe_path
    protocol            = "Http"
    request_type        = "GET"
  }
}

resource "azurerm_cdn_frontdoor_origin" "main" {
  for_each                       = var.origins
  name                           = each.key
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.main[each.value.origin_group_name].id
  enabled                        = true
  host_name                      = each.value.host_name
  origin_host_header             = each.value.host_header != "" ? each.value.host_header : each.value.host_name
  http_port                      = each.value.http_port
  https_port                     = each.value.https_port
  priority                       = each.value.priority
  weight                         = each.value.weight
  certificate_name_check_enabled = each.value.certificate_name_check_enabled
}

resource "azurerm_cdn_frontdoor_custom_domain" "main" {
  for_each                 = var.custom_domains
  name                     = replace(each.key, ".", "-")
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  dns_zone_id              = each.value.dns_zone_id
  host_name                = each.key

  tls {
    certificate_type = "ManagedCertificate"
  }
}

resource "azurerm_cdn_frontdoor_route" "main" {
  for_each                      = var.routes
  name                          = each.key
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main[each.value.origin_group_name].id
  cdn_frontdoor_origin_ids      = [for origin_name in each.value.origin_names : azurerm_cdn_frontdoor_origin.main[origin_name].id]
  enabled                       = true
  forwarding_protocol           = each.value.forwarding_protocol
  https_redirect_enabled        = true
  patterns_to_match             = each.value.patterns_to_match
  supported_protocols           = ["Http", "Https"]
  link_to_default_domain        = true
  cdn_frontdoor_custom_domain_ids = [
    for domain_name in each.value.custom_domain_names :
    azurerm_cdn_frontdoor_custom_domain.main[domain_name].id
  ]
}

resource "azurerm_cdn_frontdoor_security_policy" "main" {
  count                    = var.enable_waf ? 1 : 0
  name                     = "security-policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.main.id
      association {
        patterns_to_match = ["/*"]
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.main.id
        }
      }
    }
  }
}
