# firehose

## Function

- Create a Kinesis Firehose that writes to a specific S3 bucket.

## Module location(to give a frame of reference where it's used)

- Child module of video_detail

## Contains the following terraform files

firehose.tf - creates a kinesis firehose.  
variables.tf - variables needed by this module.

## Variables

| Name                     | Description                                                                                                                                                                                                                                                                                                                 |  Type  | Default | Required |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----: | :-----: | :------: |
| name                     | Name of the firehose.                                                                                                                                                                                                                                                                                                       | string |         |   yes    |
| tags                     | A map of the tags to apply to various resources. The required tags are: <br>+ `application`, name of the app <br>+ `environment`, the environment being created <br>+ `team`, team responsible for the application <br>+ `contact-email`, contact email for the _team_ <br>+ `customer`, who the application was create for |  map   | `<map>` |   yes    |
| firehose_buffer_size     | The firehose buffer size                                                                                                                                                                                                                                                                                                    |  int   |         |   yes    |
| firehose_buffer_interval | The firehose buffer interval                                                                                                                                                                                                                                                                                                |  int   |         |   yes    |
| kds_arn                  | The arn of kinesis data stream to read from                                                                                                                                                                                                                                                                                 | string |         |   yes    |
| kms_kds_arn              | The arn of the kms key of the kinesis data stream to read from                                                                                                                                                                                                                                                              | string |         |   yes    |
| kms_s3_arn               | The arn of the kms key of the s3 bucket being written to                                                                                                                                                                                                                                                                    | string |         |   yes    |
| s3_target_arn            | The arn of the s3 bucket being written to                                                                                                                                                                                                                                                                                   | string |         |   yes    |
| prefix                   | The prefix of where the firehose will write the files                                                                                                                                                                                                                                                                       | string |         |   yes    |
