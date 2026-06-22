variable "name_prefix" { type = string }
variable "name" {
  type    = string
  default = null
}
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tenant_id" { type = string }
variable "public_network_access_enabled" {
  type    = bool
  default = true
}
variable "tags" { type = map(string) }
