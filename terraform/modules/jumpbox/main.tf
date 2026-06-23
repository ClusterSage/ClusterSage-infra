resource "azurerm_public_ip" "this" {
  count               = var.enabled ? 1 : 0
  name                = "pip-${var.name_prefix}-jumpbox"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_security_group" "this" {
  count               = var.enabled ? 1 : 0
  name                = "nsg-${var.name_prefix}-jumpbox"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = toset(var.allowed_ssh_cidrs)

    content {
      name                       = "allow-ssh-${replace(replace(security_rule.value, ".", "-"), "/", "-")}"
      priority                   = 100 + index(var.allowed_ssh_cidrs, security_rule.value)
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_network_interface" "this" {
  count               = var.enabled ? 1 : 0
  name                = "nic-${var.name_prefix}-jumpbox"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this[0].id
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  count                     = var.enabled ? 1 : 0
  network_interface_id      = azurerm_network_interface.this[0].id
  network_security_group_id = azurerm_network_security_group.this[0].id
}

resource "azurerm_linux_virtual_machine" "this" {
  count                           = var.enabled ? 1 : 0
  name                            = "vm-${var.name_prefix}-jumpbox"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.this[0].id]
  tags                            = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.yaml.tftpl", {
    admin_username = var.admin_username
  }))

  boot_diagnostics {}
}
