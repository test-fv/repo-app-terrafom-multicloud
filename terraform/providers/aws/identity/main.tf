############################################################
# Current AWS Context
############################################################

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

############################################################
# IAM Role
############################################################

resource "aws_iam_role" "ec2_role" {

  name = "${var.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]

  })

}

############################################################
# AWS Managed Policies
############################################################

resource "aws_iam_role_policy_attachment" "ecr_readonly" {

  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}

resource "aws_iam_role_policy_attachment" "ssm_core" {

  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

############################################################
# CloudWatch Agent
############################################################

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {

  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}

############################################################
# Runtime Bucket
############################################################

resource "aws_s3_bucket" "runtime" {

  bucket = lower(
    "${var.name_prefix}-runtime-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  )

  lifecycle {

    prevent_destroy = true

  }

  tags = {

    Name = "${var.name_prefix}-runtime"

  }

}

############################################################
# Runtime Bucket Public Access
############################################################

resource "aws_s3_bucket_public_access_block" "runtime" {

  bucket = aws_s3_bucket.runtime.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true

}

############################################################
# Runtime Bucket Versioning
############################################################

resource "aws_s3_bucket_versioning" "runtime" {

  bucket = aws_s3_bucket.runtime.id

  versioning_configuration {

    status = "Enabled"

  }

}

############################################################
# Runtime Bucket Encryption
############################################################

resource "aws_s3_bucket_server_side_encryption_configuration" "runtime" {

  bucket = aws_s3_bucket.runtime.id

  rule {

    apply_server_side_encryption_by_default {

      sse_algorithm = "AES256"

    }

  }

}

############################################################
# Runtime Bucket IAM Policy
############################################################

resource "aws_iam_policy" "runtime_bucket" {

  name = "${var.name_prefix}-runtime-policy"

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Sid = "RuntimeBucket"

        Effect = "Allow"

        Action = [

          "s3:GetObject",
          "s3:ListBucket"

        ]

        Resource = [

          aws_s3_bucket.runtime.arn,
          "${aws_s3_bucket.runtime.arn}/*"

        ]

      }

    ]

  })

}

resource "aws_iam_role_policy_attachment" "runtime_bucket" {

  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.runtime_bucket.arn

}

############################################################
# Instance Profile
############################################################

resource "aws_iam_instance_profile" "profile" {

  name = "${var.name_prefix}-instance-profile"

  role = aws_iam_role.ec2_role.name

}