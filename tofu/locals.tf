locals {
  common_tags = merge(var.tags, {
    Project   = "org-security-alerting"
    ManagedBy = "opentofu"
  })
}
