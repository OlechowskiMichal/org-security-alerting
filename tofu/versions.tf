terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "REPLACE_BUCKET_NAME"
    key            = "security-alerting/terraform.tfstate"
    region         = "REPLACE_REGION"
    dynamodb_table = "REPLACE_DYNAMODB_TABLE"
    encrypt        = true
  }
}
