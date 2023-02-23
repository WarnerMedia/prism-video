#! /bin/bash
set -e

export AWS_PROFILE=
export AWS_DEFAULT_REGION=us-east-1

aws lambda update-function-code \
  --function-name late_s3_metrics \
  --zip-file fileb://late_s3_metrics.zip | jq
