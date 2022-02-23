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

resource "azurerm_public_ip" "kloudtom_public_ip" {
	count               = "${var.number_of_nodes}"
  name                = "kloudtom_public_ip${count.index + 1}"
  location            = azurerm_resource_group.kloudtom_rg.location
  resource_group_name = azurerm_resource_group.kloudtom_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "kloudtom_interface" {
	count               = "${var.number_of_nodes}"
	name = "kloudtom_interface${count.index + 1}"
	location = azurerm_resource_group.kloudtom_rg.location
	resource_group_name = azurerm_resource_group.kloudtom_rg.name
	ip_configuration {
		name = "kloudtom_internal"
		subnet_id = azurerm_subnet.kloudtom_subnet.id
		private_ip_address_allocation = "Dynamic"
		public_ip_address_id = azurerm_public_ip.kloudtom_public_ip[count.index].id

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
	count               = "${var.number_of_nodes}"
	name = "${var.vm_name_prefix1}-vm-${count.index + 1}"
	location = azurerm_resource_group.kloudtom_rg.location
	resource_group_name = azurerm_resource_group.kloudtom_rg.name
	network_interface_ids = [azurerm_network_interface.kloudtom_interface[count.index].id]
	vm_size               = "Standard_DS1_v2"
	delete_os_disk_on_termination = true
	delete_data_disks_on_termination = true

	storage_image_reference {
    	publisher = "Canonical"
    	offer     = "0001-com-ubuntu-server-focal"
    	sku       = "20_04-lts"
    	version   = "latest"
	}
	storage_os_disk {
    	name              = "myosdisk-${count.index + 1}"
    	caching           = "ReadWrite"
    	create_option     = "FromImage"
    	managed_disk_type = "Standard_LRS"
  	}
	os_profile {
    	computer_name  = "jenkins-master-vm"
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