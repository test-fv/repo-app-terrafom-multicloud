output "public_ip" {

  description = "Public Elastic IP assigned to the EC2 instance."

  value = aws_eip.vm_ip.public_ip

}

output "instance_id" {

  description = "EC2 instance identifier."

  value = aws_instance.vm.id

}