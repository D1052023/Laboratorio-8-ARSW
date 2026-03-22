variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "prefix" { type = string }
variable "admin_username" { type = string }
variable "ssh_public_key" { type = string }
variable "subnet_id" { type = string }
variable "vm_count" { type = number }
variable "cloud_init" { type = string }
variable "tags" { type = map(string) }

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "${var.prefix}-vmss"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku       = "Standard_B1s"
  instances = var.vm_count

  admin_username = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      subnet_id = var.subnet_id
    }
  }

  custom_data = base64encode(var.cloud_init)

  upgrade_mode = "Automatic"

  tags = var.tags
}