output "instance_profile_name" {

  description = "IAM Instance Profile attached to EC2 instances."

  value = aws_iam_instance_profile.profile.name

}