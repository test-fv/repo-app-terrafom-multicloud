output "public_ip" {
  value = aws_eip.vm_ip.public_ip
}

output "instance_id" {
  value = aws_instance.vm.id
}