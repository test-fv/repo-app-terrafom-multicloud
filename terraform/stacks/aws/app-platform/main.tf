module "network" {

  source = "../../../providers/aws/network"

  name_prefix = var.name_prefix

  vpc_cidr    = var.vpc_cidr
  subnet_cidr = var.subnet_cidr

  tags = var.tags

}

module "registry" {

  source = "../../../providers/aws/registry"

  repository_name = var.repository_name

  tags = var.tags

}

module "identity" {

  source = "../../../providers/aws/identity"

  name_prefix = var.name_prefix

}

module "compute" {

  source = "../../../providers/aws/compute"

  name_prefix   = var.name_prefix
  instance_type = var.instance_type
  aws_region    = var.aws_region

  registry_url = module.registry.registry_url

  instance_profile_name = module.identity.instance_profile_name

  ############################################################
  # Runtime
  ############################################################

  runtime_bucket_name = module.identity.runtime_bucket_name

  ############################################################

  subnet_id         = module.network.subnet_id
  security_group_id = module.network.security_group_id

  tags = var.tags

}

module "monitoring" {

  source = "../../../providers/aws/monitoring"

  instance_id = module.compute.instance_id

  name_prefix = var.name_prefix

  tags = var.tags

  alarm_actions = [

    module.monitoring_alerts.sns_topic_arn

  ]

}

module "monitoring_alerts" {

  source = "../../../providers/aws/monitoring-alerts"

  name_prefix = var.name_prefix

  notification_email = var.notification_email

  tags = var.tags

}