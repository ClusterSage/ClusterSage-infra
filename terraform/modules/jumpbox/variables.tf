variable "enabled" {
  type    = bool
  default = true
}

variable "name_prefix" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "subnet_id" { type = string }
variable "admin_username" { type = string }
variable "ssh_public_key" { type = string }
variable "vm_size" { type = string }
variable "allowed_ssh_cidrs" { type = list(string) }
variable "tags" { type = map(string) }
