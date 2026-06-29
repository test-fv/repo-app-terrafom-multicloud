############################################################
# IAM
############################################################

output "instance_profile_name" {

  description = "IAM Instance Profile attached to EC2 instances."

  value = aws_iam_instance_profile.profile.name

}

############################################################
# Runtime Bucket
############################################################

output "runtime_bucket_name" {

  description = "Private S3 bucket containing the deployment runtime."

  value = aws_s3_bucket.runtime.bucket

}

output "runtime_bucket_arn" {

  description = "Runtime bucket ARN."

  value = aws_s3_bucket.runtime.arn

}