resource "azurerm_virtual_network" "vnet" {
  name                = "${var.name_prefix}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = ["10.0.0.0/16"]

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.name_prefix}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name_prefix}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags

  security_rule {
    name      = "allow-https"
    priority  = 1003
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"

    source_port_range      = "*"
    destination_port_range = "443"

    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name      = "allow-ssh"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_http" {
  name      = "allow-http"
  priority  = 101
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "80"

  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_https" {
  name      = "allow-https"
  priority  = 102
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "443"

  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}