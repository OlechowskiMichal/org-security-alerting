variable "kms_key_id" {
  description = "KMS key ID for SNS topic encryption"
  type        = string
}

variable "alert_email" {
  description = "Email address for security alert notifications"
  type        = string
  sensitive   = true
}
