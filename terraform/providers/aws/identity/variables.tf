variable "name_prefix" {

  description = "Prefix used to name IAM resources."

  type = string

}

variable "runtime_bucket_prevent_destroy" {

  description = "Prevent accidental destruction of the runtime bucket."

  type = bool

  default = true

}