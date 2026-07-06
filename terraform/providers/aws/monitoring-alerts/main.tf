############################################################
# SNS Topic
############################################################

resource "aws_sns_topic" "infrastructure" {

  name = "${var.name_prefix}-alerts"

  tags = var.tags

}

############################################################
# Email Subscription
############################################################

resource "aws_sns_topic_subscription" "email" {

  topic_arn = aws_sns_topic.infrastructure.arn

  protocol = "email"

  endpoint = var.notification_email

}