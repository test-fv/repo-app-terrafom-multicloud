# outputs.tf for compute
output "public_ip" {
  value = azurerm_public_ip.ip.ip_address
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}

output "ssh_private_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}