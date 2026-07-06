variable "instance_id" {

  type = string

}

variable "name_prefix" {

  type = string

}

variable "tags" {

  type = map(string)

}

variable "alarm_actions" {

  description = "SNS topics triggered when alarm enters ALARM."

  type = list(string)

  default = []

}