provider "azurerm" {
    features {}
    subscription_id = ?
}
resource "azurerm_resource_group" "textrg" {
    name = "textrg"
    location = "Central India"
}

resource "azurerm_virtual_network" "textvnet" {
    name = "textvnet"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.textrg.location
    resource_group_name = azurerm_resource_group.textrg.name
}
resource "azurerm_subnet" "textsubnet" {
    name = "textsubnet"
    resource_group_name = azurerm_resource_group.textrg.name
    virtual_network_name = azurerm_virtual_network.textvnet.name
    address_prefixes = ["10.0.1.0/24"]
}
resource "azurerm_network_security_group" "textnsg" {
    name = "textnsg"
    location = azurerm_resource_group.textrg.location
    resource_group_name = azurerm_resource_group.textrg.name
    
    security_rule {
        name = "ssh"
        priority = 1001
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"

    }
}
resource "azurerm_network_interface" "textnic" {
    name = "textnic"
    location = azurerm_resource_group.textrg.location
    resource_group_name = azurerm_resource_group.textrg.name

    ip_configuration {
        name = "ipconfig"
        subnet_id = azurerm_subnet.textsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.public_ip.id
    }
}
resource "azurerm_public_ip" "public_ip" {
    name = "public_ip_text"
    resource_group_name = azurerm_resource_group.textrg.name
    location = azurerm_resource_group.textrg.location
    allocation_method = "Static"
}
resource "azurerm_network_interface_security_group_association" "textnic_textnsg" {
  network_interface_id      = azurerm_network_interface.textnic.id
  network_security_group_id = azurerm_network_security_group.textnsg.id
}
resource "azurerm_linux_virtual_machine" "textvm" {
  name                = "textvm"
  resource_group_name = azurerm_resource_group.textrg.name
  location            = azurerm_resource_group.textrg.location
  size                = "Standard_D2as_v5"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.textnic.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:\\Users\\Haritha\\.ssh\\id_ed25519.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
