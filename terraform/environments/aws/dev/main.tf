module "platform" {
  source = "../../../stacks/aws/app-platform"

  name_prefix = local.name_prefix

  instance_type = local.instance_type

  repository_name = local.repository_name

  aws_region = local.aws_region

  tags = local.common_tags
}