output "registry_url" {

  description = "Full ECR repository URL."

  value = aws_ecr_repository.ecr.repository_url

}

output "registry_server" {

  description = "ECR registry hostname."

  value = split("/", aws_ecr_repository.ecr.repository_url)[0]

}

output "repository_name" {

  description = "ECR repository name."

  value = aws_ecr_repository.ecr.name

}