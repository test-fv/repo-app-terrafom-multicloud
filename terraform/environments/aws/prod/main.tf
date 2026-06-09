module "platform" {
  source = "../../../stacks/aws/app-platform"

  name_prefix = local.name_prefix

  instance_type = var.instance_type

  repository_name = var.repository_name

  aws_region = local.aws_region

  tags = local.common_tags
}