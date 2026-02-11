variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for CloudTrail metric filters"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm actions"
  type        = string
}
