# lambda_s3_notifier

## Function

- Creates the link between an s3 bucket and a lambda function to allow events to be sent when files are dropped into s3.

## Module location(to give a frame of reference where it's used)

- Child module of video_destination

## Contains the following terraform files

lambda_s3_notifier.tf - main terraform to provide lambda with notification from s3.
variables.tf - variables needed by this module.

## Variables

| Name                | Description                            |  Type  | Default | Required |
| ------------------- | -------------------------------------- | :----: | :-----: | :------: |
| lambda_function_arn | ARN of the lambda s3 metrics function. | string |         |   yes    |
| s3_bucket_arn       | ARN of the s3 late bucket.             | string |         |   yes    |
| s3_bucket_id        | id of the s3 late bucket.              | string |         |   yes    |
