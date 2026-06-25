variable "name_prefix" { type = string }
variable "resource_group_name" { type = string }
variable "sku_name" { type = string }
variable "tags" { type = map(string) }

variable "enable_waf" {
  type    = bool
  default = true
}

variable "waf_mode" {
  type    = string
  default = "Prevention"
}

variable "origin_groups" {
  type = map(object({
    health_probe_path = string
  }))
}

variable "origins" {
  type = map(object({
    origin_group_name              = string
    host_name                      = string
    host_header                    = optional(string, "")
    http_port                      = optional(number, 80)
    https_port                     = optional(number, 443)
    priority                       = optional(number, 1)
    weight                         = optional(number, 1000)
    certificate_name_check_enabled = optional(bool, false)
  }))
}

variable "custom_domains" {
  type = map(object({
    dns_zone_id = optional(string)
  }))
  default = {}
}

variable "routes" {
  type = map(object({
    origin_group_name   = string
    origin_names        = list(string)
    patterns_to_match   = list(string)
    custom_domain_names = optional(list(string), [])
    forwarding_protocol = optional(string, "HttpOnly")
    cache = optional(object({
      compression_enabled           = optional(bool)
      content_types_to_compress     = optional(list(string))
      query_string_caching_behavior = optional(string)
      query_strings                 = optional(list(string))
    }))
  }))
}
