module "sns" {
  source = "./modules/sns"

  kms_key_id  = var.kms_key_id
  alert_email = var.alert_email
}

module "metric_alarms" {
  source = "./modules/metric_alarms"

  cloudwatch_log_group_name = var.cloudwatch_log_group_name
  sns_topic_arn             = module.sns.topic_arn
}

module "eventbridge" {
  source = "./modules/eventbridge"

  sns_topic_arn = module.sns.topic_arn
}
