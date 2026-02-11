# --------------------------------------------------------------------------
# Metric Filters and Alarms - Root account usage
# --------------------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "root_account_usage" {
  name           = "RootAccountUsage"
  log_group_name = var.cloudwatch_log_group_name

  pattern = "{ ($.userIdentity.type = \"Root\") && ($.userIdentity.invokedBy NOT EXISTS) && ($.eventType != \"AwsServiceEvent\") }"

  metric_transformation {
    name          = "RootAccountUsage"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "root_account_usage" {
  alarm_name          = "root-account-usage"
  alarm_description   = "Triggers when the root account is used"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "RootAccountUsage"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [var.sns_topic_arn]
}

# --------------------------------------------------------------------------
# Metric Filters and Alarms - Console sign-in without MFA
# --------------------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "console_signin_without_mfa" {
  name           = "ConsoleSignInWithoutMFA"
  log_group_name = var.cloudwatch_log_group_name

  pattern = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") && ($.userIdentity.type = \"IAMUser\") }"

  metric_transformation {
    name          = "ConsoleSignInWithoutMFA"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "console_signin_without_mfa" {
  alarm_name          = "console-signin-without-mfa"
  alarm_description   = "Triggers when an IAM user signs in to the console without MFA"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ConsoleSignInWithoutMFA"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "notBreaching"

  alarm_actions = [var.sns_topic_arn]
}
