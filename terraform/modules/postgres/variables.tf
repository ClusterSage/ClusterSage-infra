variable "name_prefix" { type = string }
variable "database_name" { type = string }
variable "server_name" {
  type    = string
  default = null
}
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "administrator_login" { type = string }
variable "administrator_password" {
  type      = string
  sensitive = true
}
variable "sku_name" { type = string }
variable "storage_mb" { type = number }
variable "private_dns_zone_id" {
  type    = string
  default = null
}
variable "public_network_access_enabled" {
  type    = bool
  default = true
}
variable "replica_public_network_access_enabled" {
  type    = bool
  default = null
}
variable "create_azure_services_firewall_rule" {
  type    = bool
  default = true
}
variable "tags" { type = map(string) }

variable "create_replica" {
  type    = bool
  default = false
}

variable "replica_name" {
  type    = string
  default = null
}

variable "replica_location" {
  type    = string
  default = null
}
