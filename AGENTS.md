# Agent Instructions: org-security-alerting

## Overview

Standalone OpenTofu module for organization-wide security alerting. Deploys SNS topic, CloudWatch metric filters/alarms for CloudTrail log analysis, and EventBridge rules for GuardDuty/SecurityHub findings. Designed to consume outputs from org-cloudtrail (KMS key ID, CloudWatch log group name).

## Tech Stack

| Component | Tool | Version |
|-----------|------|---------|
| IaC | OpenTofu | ~> 1.9 |
| Cloud | AWS | ~> 5.0 provider |
| Testing | Go + Terratest | 1.23 |
| Local testing | LocalStack | 4.x |
| Linting | golangci-lint | 1.62 (custom build) |
| CI/CD | GitHub Actions | v4 |
| Task runner | Task | 3.x |
| Tool management | mise | latest |
| Git hooks | lefthook | latest |
| Commit lint | commitlint | 19.x |
| Terraform lint | tflint | latest (AWS plugin) |

## Key Files

```text
tofu/main.tf                    # All alerting resources (SNS, metric filters, EventBridge)
tofu/variables.tf               # Input variables (KMS key ID, log group name, email, region)
tofu/outputs.tf                 # sns_topic_arn
conftest.toml                   # OPA policy config
```

## Module Resources

| Resource | Account | Purpose |
|----------|---------|---------|
| SNS topic | Management | Security alert notifications (KMS encrypted) |
| SNS email subscription | Management | Alert delivery to email |
| Metric filters + alarms | Management | Unauthorized API, root usage, MFA-less sign-in |
| EventBridge rules | Management | GuardDuty + SecurityHub high/critical findings |

## Provider Configuration

This module requires a single AWS provider configuration:

- `aws` -- management account (default)

## Input Dependencies

This module consumes outputs from `org-cloudtrail`:

| Variable | Source |
|----------|--------|
| `kms_key_id` | `org-cloudtrail.kms_key_id` |
| `cloudwatch_log_group_name` | `org-cloudtrail.cloudwatch_log_group_name` |

## Commands

```bash
task setup              # Install tools and git hooks
task tofu:fmt           # Format OpenTofu files
task tofu:validate      # Init and validate
task tofu:tflint        # Run tflint
task tofu:trivy         # Scan for security issues
task lint:go            # Run golangci-lint
task test:unit          # Unit tests
task test:integration   # Integration tests (LocalStack)
task ci:validate        # Full CI validation
```

## Development Guidelines

- Follow existing HCL patterns and naming conventions
- Conventional commits enforced via lefthook
- Use feature branches, create PRs
- Run `task ci:validate` before pushing
- Go source files must be <= 120 lines (test files excluded)
