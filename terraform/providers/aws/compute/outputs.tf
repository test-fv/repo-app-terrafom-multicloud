output "public_ip" {

  description = "Public Elastic IP assigned to the EC2 instance."

  value = aws_eip.vm_ip.public_ip

}

output "instance_id" {

  description = "EC2 instance identifier."

  value = aws_instance.vm.id

}

output "ssh_private_key" {

  description = "Generated SSH private key used for instance access."

  value = tls_private_key.ssh.private_key_pem

  sensitive = true

}