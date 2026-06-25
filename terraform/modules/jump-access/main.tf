terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

resource "azurerm_resource_group" "this" {
  count    = var.enabled ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_network" "this" {
  count               = var.enabled ? 1 : 0
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.this[0].name
  location            = azurerm_resource_group.this[0].location
  address_space       = var.vnet_address_space
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet" "this" {
  count                = var.enabled ? 1 : 0
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.this[0].name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = var.subnet_prefixes

  default_outbound_access_enabled   = false
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_virtual_network_peering" "prod_to_jump" {
  count                     = var.enabled ? 1 : 0
  name                      = var.prod_to_jump_peering_name
  resource_group_name       = var.prod_resource_group_name
  virtual_network_name      = var.prod_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.this[0].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "jump_to_prod" {
  count                     = var.enabled ? 1 : 0
  name                      = var.jump_to_prod_peering_name
  resource_group_name       = azurerm_resource_group.this[0].name
  virtual_network_name      = azurerm_virtual_network.this[0].name
  remote_virtual_network_id = var.prod_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_public_ip" "vm" {
  count               = var.enabled ? 1 : 0
  name                = var.vm_public_ip_name
  location            = azurerm_resource_group.this[0].location
  resource_group_name = azurerm_resource_group.this[0].name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_group" "vm" {
  count               = var.enabled ? 1 : 0
  name                = var.vm_nsg_name
  location            = azurerm_resource_group.this[0].location
  resource_group_name = azurerm_resource_group.this[0].name
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }

  dynamic "security_rule" {
    for_each = var.vm_nsg_allowed_source_prefixes

    content {
      name                       = security_rule.value == "*" ? "SSH" : "ssh-${replace(replace(security_rule.value, ".", "-"), "/", "-")}"
      priority                   = 300 + index(var.vm_nsg_allowed_source_prefixes, security_rule.value)
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

resource "azurerm_network_interface" "vm" {
  count                          = var.enabled ? 1 : 0
  name                           = var.vm_nic_name
  location                       = azurerm_resource_group.this[0].location
  resource_group_name            = azurerm_resource_group.this[0].name
  accelerated_networking_enabled = true
  tags                           = var.tags

  lifecycle {
    ignore_changes = [tags]
  }

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.this[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm[0].id
  }
}

resource "azurerm_network_interface_security_group_association" "vm" {
  count                     = var.enabled ? 1 : 0
  network_interface_id      = azurerm_network_interface.vm[0].id
  network_security_group_id = azurerm_network_security_group.vm[0].id
}

resource "azapi_resource" "vm" {
  count     = var.enabled ? 1 : 0
  type      = "Microsoft.Compute/virtualMachines@2025-04-01"
  name      = var.vm_name
  parent_id = azurerm_resource_group.this[0].id
  location  = azurerm_resource_group.this[0].location

  schema_validation_enabled = true
  ignore_missing_property   = true

  body = {
    tags = var.tags
    properties = {
      additionalCapabilities = {
        hibernationEnabled = false
      }
      diagnosticsProfile = {
        bootDiagnostics = {
          enabled = true
        }
      }
      hardwareProfile = {
        vmSize = var.vm_size
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azurerm_network_interface.vm[0].id
            properties = {
              deleteOption = "Detach"
            }
          }
        ]
      }
      osProfile = {
        adminUsername               = var.vm_admin_username
        computerName                = var.vm_name
        allowExtensionOperations    = true
        requireGuestProvisionSignal = true
        secrets                     = []
        linuxConfiguration = {
          disablePasswordAuthentication = false
          patchSettings = {
            assessmentMode = "ImageDefault"
            patchMode      = "ImageDefault"
          }
          provisionVMAgent = true
        }
      }
      securityProfile = {
        securityType = "TrustedLaunch"
        uefiSettings = {
          secureBootEnabled = true
          vTpmEnabled       = true
        }
      }
      storageProfile = {
        dataDisks          = []
        diskControllerType = "SCSI"
        imageReference = {
          publisher = "canonical"
          offer     = "ubuntu-24_04-lts"
          sku       = "server"
          version   = "latest"
        }
        osDisk = {
          caching      = "ReadWrite"
          createOption = "FromImage"
          deleteOption = "Delete"
          diskSizeGB   = 30
          name         = var.vm_os_disk_name
          managedDisk = {
            storageAccountType = "Premium_LRS"
          }
          osType = "Linux"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      body.tags,
      body.properties.osProfile.adminPassword,
      body.properties.storageProfile.osDisk.name,
      body.properties.storageProfile.osDisk.managedDisk,
    ]
  }

  depends_on = [
    azurerm_network_interface_security_group_association.vm,
  ]
}

resource "azurerm_bastion_host" "this" {
  count               = var.enabled ? 1 : 0
  name                = var.bastion_name
  resource_group_name = azurerm_resource_group.this[0].name
  location            = azurerm_resource_group.this[0].location
  sku                 = "Developer"
  virtual_network_id  = azurerm_virtual_network.this[0].id
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}
