# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.90.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}  #We can keep it empty if we dont need it, but we must declare it
  # subscription_id = ""
  # client_id = ""
  # client_secret = ""
  # tenant_id = ""
}


resource "azurerm_resource_group" "rg-kfir" {
  name     = var.resource_group_name
  location = var.azurerm_resource_group_location
  tags = {
    enviroment = "dev"
  }
}
# to set high availability, we creat availability set
resource "azurerm_availability_set" "aztek-kfir-az" {
  name                = "high-avilability-aset"
  location            = azurerm_resource_group.rg-kfir.location
  resource_group_name = azurerm_resource_group.rg-kfir.name
  platform_fault_domain_count = 3 #default is 3
  tags = {
    environment = "Production"
  }
}
resource "azurerm_virtual_network" "aztek_kfir_network" {
  name                = "aztek_kfir_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-kfir.location
  resource_group_name = azurerm_resource_group.rg-kfir.name
}

resource "azurerm_subnet" "aztek-kfir-subnet" {
  name                 = "internal-sn"
  resource_group_name  = azurerm_resource_group.rg-kfir.name
  virtual_network_name = azurerm_virtual_network.aztek_kfir_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "aztek-kfir-nic" {
  name                = "aztek-kfir-nic"
  location            = azurerm_resource_group.rg-kfir.location
  resource_group_name = azurerm_resource_group.rg-kfir.name

  ip_configuration {
    name                          = "internal-ipc"
    subnet_id                     = azurerm_subnet.aztek-kfir-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine_scale_set" "win_app" {
  name                = "win-app-1"
  resource_group_name = azurerm_resource_group.rg-kfir.name
  location            = azurerm_resource_group.rg-kfir.location
  sku                 = var.azurerm_windows_virtual_machine_size
  admin_username      = var.admin_username  # can put on config file and just use it without upload
  admin_password      = var.admin_password
  instances           = 2
  depends_on = [
    azurerm_sql_server.atzek-kfir-sqlserver
  ]
  # network_interface_ids = [
  #   azurerm_network_interface.aztek-kfir-nic.id,
  # ]
  tags = {
    win-version = "2016"
    customer = "customer1"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  network_interface {
    name    = "aztek-kfir-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.aztek-kfir-subnet.id
    }
  }

}

resource "azurerm_public_ip" "aztek-kfir-pip" {
  name                = "aztek-kfir-pip"
  location            = azurerm_resource_group.rg-kfir.location
  resource_group_name = azurerm_resource_group.rg-kfir.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "aztek-kfir-lb" {
  name                = "aztek-kfir-lb"
  location            = azurerm_resource_group.rg-kfir.location
  resource_group_name = azurerm_resource_group.rg-kfir.name

  frontend_ip_configuration {
    name                 = "primary"
    public_ip_address_id = azurerm_public_ip.aztek-kfir-pip.id
  }
}

resource "azurerm_lb_nat_rule" "aztek-nat-rule" {
  resource_group_name            = azurerm_resource_group.rg-kfir.name
  loadbalancer_id                = azurerm_lb.aztek-kfir-lb.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = var.connection-port
  backend_port                   = var.connection-port
  frontend_ip_configuration_name = "primary"
}

resource "azurerm_network_interface_nat_rule_association" "aztek-nat" {
  network_interface_id  = azurerm_network_interface.aztek-kfir-nic.id
  ip_configuration_name = "internal-ipc"
  nat_rule_id           = azurerm_lb_nat_rule.aztek-nat-rule.id
}

resource "azurerm_lb_backend_address_pool" "BE-pool" {
  loadbalancer_id = azurerm_lb.aztek-kfir-lb.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_security_group" "aztek-kfir-nsg" {
  name                = "aztek-kfir-nsg"
  location            = azurerm_resource_group.rg-kfir.location
  resource_group_name = azurerm_resource_group.rg-kfir.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = var.connection-port
    destination_port_range     = var.connection-port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_rule" "allow_management_inbound" {
  name                        = "allow_management_inbound"
  priority                    = 106
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = var.connection-port-range
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-kfir.name
  network_security_group_name = azurerm_network_security_group.aztek-kfir-nsg.name
}


resource "azurerm_network_interface_security_group_association" "aztek-kfir-nsga" {
  network_interface_id      = azurerm_network_interface.aztek-kfir-nic.id
  network_security_group_id = azurerm_network_security_group.aztek-kfir-nsg.id
}

data "azurerm_sql_server" "atzek-kfir-sqlserver" {
  name                = "atzek-kfir-sqlserver"
  resource_group_name = azurerm_resource_group.rg-kfir.name
  depends_on = [
    azurerm_sql_server.atzek-kfir-sqlserver
  ]
}
# #test
# output "id" {
#   value = data.azurerm_sql_server.atzek-kfir-sqlserver.id
# }




# #depends_on ## sql