output "registry_url" {
  value = aws_ecr_repository.ecr.repository_url
}

output "registry_server" {
  value = split("/", aws_ecr_repository.ecr.repository_url)[0]
}

output "repository_name" {
  value = aws_ecr_repository.ecr.name
}