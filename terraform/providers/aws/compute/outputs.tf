output "public_ip" {
  value = aws_eip.vm_ip.public_ip
}

output "instance_id" {
  value = aws_instance.vm.id
}

output "ssh_private_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}