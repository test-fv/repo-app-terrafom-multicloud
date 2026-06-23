output "subnet_id" {

  description = "Public subnet identifier."

  value = aws_subnet.subnet.id

}

output "security_group_id" {

  description = "Security group identifier assigned to the application."

  value = aws_security_group.sg.id

}