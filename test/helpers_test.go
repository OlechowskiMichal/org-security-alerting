package test

import (
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/cloudwatchlogs"
	"github.com/aws/aws-sdk-go-v2/service/sns"
)

const (
	LocalStackEndpoint = "http://localhost:4566"
	TestRegion         = "us-east-1"
)

// awsConfigFactory is set by init() in config_localstack_test.go or config_e2e_test.go.
var awsConfigFactory func() (aws.Config, error)

// endpointOverride is set by init() in the config files. Empty string means no override.
var endpointOverride string

func getAWSConfig() (aws.Config, error) {
	return awsConfigFactory()
}

func newSNSClient(cfg *aws.Config) *sns.Client {
	return sns.NewFromConfig(*cfg, func(o *sns.Options) {
		if endpointOverride != "" {
			o.BaseEndpoint = aws.String(endpointOverride)
		}
	})
}

func newCloudWatchLogsClient(cfg *aws.Config) *cloudwatchlogs.Client {
	return cloudwatchlogs.NewFromConfig(*cfg, func(o *cloudwatchlogs.Options) {
		if endpointOverride != "" {
			o.BaseEndpoint = aws.String(endpointOverride)
		}
	})
}
