package test

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/cloudwatchlogs"
	"github.com/aws/aws-sdk-go-v2/service/sns"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestSecurityAlertingIntegration(t *testing.T) {
	t.Parallel()

	tofuOpts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir:    "./fixtures/default",
		TerraformBinary: "tofu",
	})

	defer terraform.Destroy(t, tofuOpts)
	terraform.InitAndApply(t, tofuOpts)

	snsTopicARN := terraform.Output(t, tofuOpts, "sns_topic_arn")
	require.NotEmpty(t, snsTopicARN, "sns_topic_arn output should not be empty")

	cfg, err := getAWSConfig()
	require.NoError(t, err, "failed to load AWS config")

	t.Run("sns_topic_exists", func(t *testing.T) {
		snsClient := newSNSClient(&cfg)

		attrs, err := snsClient.GetTopicAttributes(context.Background(), &sns.GetTopicAttributesInput{
			TopicArn: aws.String(snsTopicARN),
		})
		require.NoError(t, err, "SNS topic should exist: %s", snsTopicARN)
		assert.Contains(t, attrs.Attributes, "TopicArn",
			"SNS topic attributes should contain TopicArn")
	})

	t.Run("sns_email_subscription", func(t *testing.T) {
		snsClient := newSNSClient(&cfg)

		subs, err := snsClient.ListSubscriptionsByTopic(context.Background(), &sns.ListSubscriptionsByTopicInput{
			TopicArn: aws.String(snsTopicARN),
		})
		require.NoError(t, err, "should list subscriptions for topic")
		require.NotEmpty(t, subs.Subscriptions, "topic should have at least one subscription")

		found := false
		for _, sub := range subs.Subscriptions {
			if aws.ToString(sub.Protocol) == "email" && aws.ToString(sub.Endpoint) == "test@example.com" {
				found = true
				break
			}
		}
		assert.True(t, found, "email subscription for test@example.com should exist")
	})

	t.Run("cloudwatch_log_group_exists", func(t *testing.T) {
		cwlClient := newCloudWatchLogsClient(&cfg)

		resp, err := cwlClient.DescribeLogGroups(context.Background(), &cloudwatchlogs.DescribeLogGroupsInput{
			LogGroupNamePrefix: aws.String("/aws/cloudtrail/test-org-trail"),
		})
		require.NoError(t, err, "should describe log groups")
		require.NotEmpty(t, resp.LogGroups, "test log group should exist")
		assert.Equal(t, "/aws/cloudtrail/test-org-trail", aws.ToString(resp.LogGroups[0].LogGroupName),
			"log group name should match")
	})

	t.Run("metric_filters_exist", func(t *testing.T) {
		cwlClient := newCloudWatchLogsClient(&cfg)

		resp, err := cwlClient.DescribeMetricFilters(context.Background(), &cloudwatchlogs.DescribeMetricFiltersInput{
			LogGroupName: aws.String("/aws/cloudtrail/test-org-trail"),
		})
		require.NoError(t, err, "should describe metric filters")

		expectedFilters := []string{
			"UnauthorizedAPICalls",
			"RootAccountUsage",
			"ConsoleSignInWithoutMFA",
		}

		filterNames := make([]string, 0, len(resp.MetricFilters))
		for _, f := range resp.MetricFilters {
			filterNames = append(filterNames, aws.ToString(f.FilterName))
		}

		for _, expected := range expectedFilters {
			assert.Contains(t, filterNames, expected,
				"metric filter %q should exist on the log group", expected)
		}
	})
}
