# sns-event

## Function

- This terraform creates an SNS topic, applies the appropriate policies on the topic to allow Snowflake access and associate the SNS to an s3 event on the bucket defined.  
  This script should also be executed twice: first to create the SNS topic and then to update the SNS topic policy with the property snowflake_iam_user (retrieved from Snowflake).

## Contains the following terraform files

sns-event.tf - creates the trigger event on the S3 Bucket to send to the SNS topic used by Snowflake to load data.
variables.tf - variables needed by this module.
output.tf - output variables from module

## Variables

| Name               | Description                     |  Type  | Default | Required |
| ------------------ | ------------------------------- | :----: | :-----: | :------: |
| s3_bucket_name     | Name of the S3 bucket.          | string |         |   yes    |
| snowflake_iam_user | Name of the Snowflake IAM User. | string |         |   yes    |
| name               | Name of the SNS Topic.          | string |         |   yes    |
