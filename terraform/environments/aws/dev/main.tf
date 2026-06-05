module "platform" {
  source = "../../../stacks/aws/app-platform"

  name_prefix = local.name_prefix

  instance_type = var.instance_type

  repository_name = var.repository_name

  aws_region = var.aws_region

  ssh_public_key = var.ssh_public_key

  tags = local.common_tags
}