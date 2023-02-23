#! /bin/bash
set -e

export AWS_PROFILE=
export AWS_DEFAULT_REGION=us-east-1

aws lambda update-function-code \
  --function-name kds_timestream_buf_sess \
  --zip-file fileb://kds_timestream_buf_sess.zip | jq