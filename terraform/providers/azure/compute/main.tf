resource "azurerm_public_ip" "ip" {
  name                = "${var.name_prefix}-ip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"

  tags = var.tags
}
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.name_prefix}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"

    public_ip_address_id = azurerm_public_ip.ip.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.name_prefix}-vm"
  location            = var.location
  resource_group_name = var.resource_group_name

  size = var.vm_size

  admin_username = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  disable_password_authentication = true

  boot_diagnostics {}

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh.public_key_openssh
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

  custom_data = base64encode(
    templatefile("${path.module}/cloud-init.yaml", {

      admin_username = var.admin_username

      deploy_sh = file("${path.root}/../../../contracts/runtime/deploy.sh")

      azure_provider_sh = file("${path.root}/../../../scripts/runtime/providers/azure.sh")

      aws_provider_sh = file("${path.root}/../../../scripts/runtime/providers/aws.sh")
    })
  )

  identity {
    type = "UserAssigned"

    identity_ids = [
      var.identity_id
    ]
  }
  tags = var.tags
}