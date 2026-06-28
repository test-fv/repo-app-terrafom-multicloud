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

##########################################################
# ECR ReadOnly
##########################################################

resource "aws_iam_role_policy_attachment" "ecr_readonly" {

  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}

##########################################################
# AWS Systems Manager
##########################################################

resource "aws_iam_role_policy_attachment" "ssm_core" {

  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}

##########################################################
# Instance Profile
##########################################################

resource "aws_iam_instance_profile" "profile" {

  name = "${var.name_prefix}-instance-profile"

  role = aws_iam_role.ec2_role.name

}