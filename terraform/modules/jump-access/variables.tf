variable "enabled" {
  type    = bool
  default = false
}

variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_name" { type = string }
variable "vnet_address_space" { type = list(string) }
variable "subnet_name" { type = string }
variable "subnet_prefixes" { type = list(string) }
variable "prod_vnet_id" { type = string }
variable "prod_vnet_name" { type = string }
variable "prod_resource_group_name" { type = string }
variable "prod_to_jump_peering_name" { type = string }
variable "jump_to_prod_peering_name" { type = string }
variable "vm_name" { type = string }
variable "vm_admin_username" { type = string }
variable "vm_size" { type = string }
variable "vm_public_ip_name" { type = string }
variable "vm_nic_name" { type = string }
variable "vm_nsg_name" { type = string }
variable "vm_nsg_allowed_source_prefixes" { type = list(string) }
variable "bastion_name" { type = string }
variable "vm_os_disk_name" { type = string }
variable "tags" { type = map(string) }
