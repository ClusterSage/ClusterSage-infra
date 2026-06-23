output "vm_name" {
  value = var.enabled ? azurerm_linux_virtual_machine.this[0].name : null
}

output "public_ip" {
  value = var.enabled ? azurerm_public_ip.this[0].ip_address : null
}

output "private_ip" {
  value = var.enabled ? azurerm_network_interface.this[0].private_ip_address : null
}
