module "platform" {

  source = "../../../stacks/aws/app-platform"

  name_prefix = local.name_prefix

  instance_type = local.instance_type

  repository_name = local.repository_name

  aws_region = local.aws_region

  vpc_cidr = local.vpc_cidr

  subnet_cidr = local.subnet_cidr

  tags = local.common_tags

}