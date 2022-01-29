provider "azurerm" {
	features {}
}

resource "azurerm_resource_group" "kloudtom_rg" {
	name = "kloudtom_rg"
	location = "southindia"
}

resource "azurerm_virtual_network" "kloudtom_network" {
	name = "kloudtom_network"
	location = azurerm_resource_group.kloudtom_rg.location
	resource_group_name = azurerm_resource_group.kloudtom_rg.name
	address_space = "${var.address_spaces}"
}

resource "azurerm_subnet" "kloudtom_subnet" {
	name = "kloudtom_subnet1"
	resource_group_name = azurerm_resource_group.kloudtom_rg.name
	virtual_network_name = azurerm_virtual_network.kloudtom_network.name
	address_prefixes = var.address_prefix
}

resource "azurerm_network_interface" "kloudtom_interface1" {
	name = "kloudtom_network_interface1"
	location = azurerm_resource_group.kloudtom_rg.location
	resource_group_name = azurerm_resource_group.kloudtom_rg.name
	ip_configuration {
		name = "kloudtom_internal"
		subnet_id = azurerm_subnet.kloudtom_subnet.id
		private_ip_address_allocation = "Dynamic"

	}
}

resource "azurerm_network_security_group" "kloudtom_sg" {
  name                = "kloudtom_sg"
  location            = azurerm_resource_group.kloudtom_rg.location
  resource_group_name = azurerm_resource_group.kloudtom_rg.name

  security_rule {
    name                       = "kloudtom_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine" "kloudtom_vm" {
	name = "${var.vm_name_prefix}-vm"
	location = azurerm_resource_group.kloudtom_rg.location
	resource_group_name = azurerm_resource_group.kloudtom_rg.name
	network_interface_ids = [azurerm_network_interface.kloudtom_interface1.id]
	vm_size               = "Standard_DS1_v2"
	delete_os_disk_on_termination = true
	delete_data_disks_on_termination = true

	storage_image_reference {
    	publisher = "Canonical"
    	offer     = "UbuntuServer"
    	sku       = "16.04-LTS"
    	version   = "latest"
	}
	storage_os_disk {
    	name              = "myosdisk1"
    	caching           = "ReadWrite"
    	create_option     = "FromImage"
    	managed_disk_type = "Standard_LRS"
  	}
	os_profile {
    	computer_name  = "kloudtom-staging-vm"
    	admin_username = "kloudtom"
    	admin_password = "Password1234!"
  	}
  	os_profile_linux_config {
    	disable_password_authentication = false
  	}
  	tags = {
    	environment = "staging"
  	}
}