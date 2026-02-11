module "security_alerting" {
  source = "../../../tofu/modules/sns"

  kms_key_id  = aws_kms_key.test.id
  alert_email = "test@example.com"
}

module "metric_alarms" {
  source = "../../../tofu/modules/metric_alarms"

  cloudwatch_log_group_name = aws_cloudwatch_log_group.test.name
  sns_topic_arn             = module.security_alerting.topic_arn
}

module "eventbridge" {
  source = "../../../tofu/modules/eventbridge"

  sns_topic_arn = module.security_alerting.topic_arn
}

resource "aws_kms_key" "test" {
  description = "Test KMS key for security alerting"
}

resource "aws_cloudwatch_log_group" "test" {
  name              = "/aws/cloudtrail/test-org-trail"
  retention_in_days = 1
}

output "sns_topic_arn" {
  value = module.security_alerting.topic_arn
}
