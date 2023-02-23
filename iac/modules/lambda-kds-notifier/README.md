# lambda_kds_notifier

## Function

- Creates the link between a kds stream and a lambda function to allow events to flow to timestream.

## Module location(to give a frame of reference where it's used)

- Child module of video_destail

## Contains the following terraform files

lambda_kds_notifire.tf - main terraform to provide lambda with events from kds.
variables.tf - variables needed by this module.

## Variables

| Name                | Description                              |  Type  | Default | Required |
| ------------------- | ---------------------------------------- | :----: | :-----: | :------: |
| lambda_function_arn | ARN of the kds timestream buf function.  | string |         |   yes    |
| kinesis_stream_arn  | ARN of the KDS stream bucket.            | string |         |   yes    |
| failed_sqs_arn      | ARN of SQS queue to send failed records. | string |         |   yes    |
