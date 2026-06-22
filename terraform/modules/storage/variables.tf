variable "name_prefix" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "container_name" { type = string }
variable "public_network_access_enabled" {
  type    = bool
  default = true
}
variable "tags" { type = map(string) }
