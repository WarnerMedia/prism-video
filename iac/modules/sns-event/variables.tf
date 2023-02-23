#
# Bucket name where the sns will be attached to. It will be used to create the topic name and assign the proper policy
#
variable "s3_bucket_name" { }

# IAM user provided by Snowflake using the command select system$get_aws_sns_iam_policy('<WM SNS topic ARN');
# start with any valid user ARN in your account
#
variable "snowflake_iam_user" { }

variable "name" {}