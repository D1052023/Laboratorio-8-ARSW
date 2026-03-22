# Resource Group y wiring de módulos
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source              = "../modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  prefix              = var.prefix
  tags                = var.tags
}

module "compute" {
  source              = "../modules/compute"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  prefix              = var.prefix
  admin_username      = var.admin_username
  ssh_public_key      = file(var.ssh_public_key)
  subnet_id           = module.vnet.subnet_web_id
  vm_count            = var.vm_count
  cloud_init          = file("${path.module}/cloud-init.yaml")
  tags                = var.tags
}

module "lb" {
  source              = "../modules/lb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  prefix              = var.prefix
  backend_nic_ids     = module.compute.nic_ids
  allow_ssh_from_cidr = var.allow_ssh_from_cidr
  tags                = var.tags
}
resource "azurerm_consumption_budget_resource_group" "budget" {
  name              = "${var.prefix}-budget"
  resource_group_id = azurerm_resource_group.rg.id
  amount            = 10 # Límite de 10 dólares
  time_grain        = "Monthly"

  time_period {
    start_date = "2026-03-01T00:00:00Z" # Mes actual
  }

  notification {
    enabled   = true
    threshold = 80.0 # Notificar al llegar a 8 USD
    operator  = "GreaterThan"
    contact_emails = [
      "oscar.sporras@mail.escuelaing.edu.co" # Cambia esto por tu correo real
    ]
  }
}