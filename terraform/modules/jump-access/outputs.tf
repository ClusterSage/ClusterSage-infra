output "resource_group_id" {
  value = var.enabled ? azurerm_resource_group.this[0].id : null
}

output "vnet_id" {
  value = var.enabled ? azurerm_virtual_network.this[0].id : null
}

output "subnet_id" {
  value = var.enabled ? azurerm_subnet.this[0].id : null
}

output "vm_public_ip" {
  value = var.enabled ? azurerm_public_ip.vm[0].ip_address : null
}

output "vm_private_ip" {
  value = var.enabled ? azurerm_network_interface.vm[0].private_ip_address : null
}

output "bastion_dns_name" {
  value = var.enabled ? azurerm_bastion_host.this[0].dns_name : null
}
