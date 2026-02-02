# -----------------------------------------------------------------------------
# CLOUDWATCH ALARMS - Security Monitoring
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "console_login_failures" {
  count = var.enable_monitoring ? 1 : 0

  alarm_name          = "jit-access-console-login-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ConsoleLoginFailures"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alert on multiple console login failures"
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "root_account_usage" {
  count = var.enable_monitoring ? 1 : 0

  alarm_name          = "jit-access-root-account-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RootAccountUsage"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alert on any root account usage"
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []
}

resource "aws_cloudwatch_metric_alarm" "iam_policy_changes" {
  count = var.enable_monitoring ? 1 : 0

  alarm_name          = "jit-access-iam-policy-changes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "IAMPolicyChanges"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alert on IAM policy changes"
  treat_missing_data  = "notBreaching"

  alarm_actions = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []
}

# -----------------------------------------------------------------------------
# CLOUDWATCH LOG METRIC FILTERS
# Requires CloudTrail logs delivered to CloudWatch
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "console_login_failure" {
  count = var.enable_monitoring && var.cloudtrail_log_group_name != null ? 1 : 0

  name           = "jit-access-console-login-failures"
  pattern        = "{ ($.eventName = ConsoleLogin) && ($.errorMessage = \"Failed authentication\") }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "ConsoleLoginFailures"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "root_account_usage" {
  count = var.enable_monitoring && var.cloudtrail_log_group_name != null ? 1 : 0

  name           = "jit-access-root-account-usage"
  pattern        = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "RootAccountUsage"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "iam_policy_changes" {
  count = var.enable_monitoring && var.cloudtrail_log_group_name != null ? 1 : 0

  name           = "jit-access-iam-policy-changes"
  pattern        = <<-PATTERN
    { ($.eventName = CreatePolicy) ||
      ($.eventName = DeletePolicy) ||
      ($.eventName = CreatePolicyVersion) ||
      ($.eventName = DeletePolicyVersion) ||
      ($.eventName = AttachRolePolicy) ||
      ($.eventName = DetachRolePolicy) ||
      ($.eventName = AttachUserPolicy) ||
      ($.eventName = DetachUserPolicy) }
  PATTERN
  log_group_name = var.cloudtrail_log_group_name

  metric_transformation {
    name      = "IAMPolicyChanges"
    namespace = "CloudTrailMetrics"
    value     = "1"
  }
}
