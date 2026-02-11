variable "kms_key_id" {
  description = "KMS key ID for SNS topic encryption"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group name for CloudTrail metric filters"
  type        = string
}

variable "alert_email" {
  description = "Email address for security alert notifications"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
