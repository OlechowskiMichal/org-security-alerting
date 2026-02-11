output "sns_topic_arn" {
  description = "ARN of the security alerts SNS topic"
  value       = module.sns.topic_arn
}
