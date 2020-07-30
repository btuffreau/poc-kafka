provider "azurerm" {
	version = "=2.18.0"
	features {}
}

resource "azurerm_resource_group" "kafka_deployment" {
	name = "kafka_lab"
	location = "North Europe"
}

resource "azurerm_virtual_network" "kafka_deployment" {
	name					= "kafka-net"
	address_space	= ["10.0.0.0/16"]
	location			= azurerm_resource_group.kafka_deployment.location
  resource_group_name = azurerm_resource_group.kafka_deployment.name
}

resource "azurerm_subnet" "kafka_deployment" {
  name                 = "kafka-subnet"
  resource_group_name  = azurerm_resource_group.kafka_deployment.name
  virtual_network_name = azurerm_virtual_network.kafka_deployment.name
  address_prefixes       = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "kafka_deployment" {

  count = 3

	name                = "kafka_public${count.index}"
	resource_group_name = azurerm_resource_group.kafka_deployment.name
  location            = azurerm_resource_group.kafka_deployment.location
	allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "kafka_deployment" {

	count = 3

  name                = "broker-nic-${count.index}"
  location            = azurerm_resource_group.kafka_deployment.location
  resource_group_name = azurerm_resource_group.kafka_deployment.name

  ip_configuration {
    name                          = "kafkanode"
    subnet_id                     = azurerm_subnet.kafka_deployment.id
    private_ip_address_allocation = "Dynamic"
		public_ip_address_id					= azurerm_public_ip.kafka_deployment[count.index].id

  }
}

resource "azurerm_virtual_machine" "kafka_deployment" {

	count = 3

	name		 = "kafka-broker-${count.index}"
	location = azurerm_resource_group.kafka_deployment.location
	resource_group_name = azurerm_resource_group.kafka_deployment.name
	network_interface_ids = [
		azurerm_network_interface.kafka_deployment[count.index].id
	]

	vm_size	 = "Standard_DS1_v2"	

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "kafkadisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "kafka-broker-${count.index}"
    admin_username = "benjamin"
  //  admin_password = "nowebs4U!" 
  }
  os_profile_linux_config {
    disable_password_authentication = true
		ssh_keys {
			key_data = file("~/.ssh/id_rsa.pub")
			path = "/home/benjamin/.ssh/authorized_keys"
		}
  }
  tags = {
    environment = "kafka-lab"
		role = "kafka"
  }

}
