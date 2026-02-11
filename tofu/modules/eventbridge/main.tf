# --------------------------------------------------------------------------
# EventBridge - GuardDuty HIGH/CRITICAL findings
# --------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "guardduty_findings" {
  name        = "guardduty-high-critical-findings"
  description = "Matches GuardDuty findings with HIGH or CRITICAL severity"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
    detail = {
      severity = [
        { numeric = [">=", 7] }
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "guardduty_sns" {
  rule      = aws_cloudwatch_event_rule.guardduty_findings.name
  target_id = "guardduty-to-sns"
  arn       = var.sns_topic_arn
}

# --------------------------------------------------------------------------
# EventBridge - SecurityHub HIGH/CRITICAL findings
# --------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "securityhub_findings" {
  name        = "securityhub-high-critical-findings"
  description = "Matches SecurityHub findings with HIGH or CRITICAL severity"

  event_pattern = jsonencode({
    source      = ["aws.securityhub"]
    detail-type = ["Security Hub Findings - Imported"]
    detail = {
      findings = {
        Severity = {
          Label = ["HIGH", "CRITICAL"]
        }
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "securityhub_sns" {
  rule      = aws_cloudwatch_event_rule.securityhub_findings.name
  target_id = "securityhub-to-sns"
  arn       = var.sns_topic_arn
}
