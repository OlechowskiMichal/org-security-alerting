# --------------------------------------------------------------------------
# Metric Filters and Alarms - Unauthorized API calls
# --------------------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "unauthorized_api_calls" {
  name           = "UnauthorizedAPICalls"
  log_group_name = var.cloudwatch_log_group_name

  pattern = "{ ($.errorCode = \"*UnauthorizedAccess*\") || ($.errorCode = \"AccessDenied*\") }"

  metric_transformation {
    name          = "UnauthorizedAPICalls"
    namespace     = "CloudTrailMetrics"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "unauthorized_api_calls" {
  alarm_name          = "unauthorized-api-calls"
  alarm_description   = "Triggers on unauthorized API calls detected by CloudTrail"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnauthorizedAPICalls"
  namespace           = "CloudTrailMetrics"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  treat_missing_data  = "notBreaching"

  alarm_actions = [var.sns_topic_arn]
}
