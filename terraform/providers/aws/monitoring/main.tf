############################################################
# High CPU
############################################################

resource "aws_cloudwatch_metric_alarm" "cpu_high" {

  alarm_name = "${var.name_prefix}-cpu-high"

  alarm_description = "CPU utilization greater than 80%."

  namespace = "AWS/EC2"

  metric_name = "CPUUtilization"

  statistic = "Average"

  period = 300

  evaluation_periods = 2

  threshold = 80

  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {

    InstanceId = var.instance_id

  }

  alarm_actions = var.alarm_actions
  
  tags = var.tags

}

############################################################
# EC2 Status Check Failed
############################################################

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {

  alarm_name = "${var.name_prefix}-status-check"
  
  alarm_actions = var.alarm_actions

  namespace = "AWS/EC2"

  metric_name = "StatusCheckFailed"

  statistic = "Maximum"

  period = 60

  evaluation_periods = 2

  threshold = 1

  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  dimensions = {

    InstanceId = var.instance_id

  }

  alarm_description = "EC2 status checks failed."

  tags = var.tags

}