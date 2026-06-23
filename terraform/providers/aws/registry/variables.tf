variable "repository_name" {

  description = "ECR repository name."

  type = string

}

variable "tags" {

  description = "Common tags applied to all resources."

  type = map(string)

}