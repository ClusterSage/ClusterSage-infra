variable "enabled" {
  type    = bool
  default = false
}
variable "name" {
  type    = string
  default = null
}
variable "name_prefix" {
  type    = string
  default = null
}
variable "zones" {
  type = map(object({
    name_prefix = string
  }))
  default = {}
}
variable "resource_group_name" { type = string }
variable "virtual_network_id" { type = string }
variable "tags" { type = map(string) }
