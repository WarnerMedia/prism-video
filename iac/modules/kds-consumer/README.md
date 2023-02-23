# kds-consummer

## Function

- Create a Kinesis Data Stream Consumer.

## Module location(to give a frame of reference where it's used)

- Child module of video_detail

## Contains the following terraform files

kds-consumer.tf - creates a kinesis data stream.  
variables.tf - variables needed by this module.

## Variables

| Name       | Description                              |  Type  | Default | Required |
| ---------- | ---------------------------------------- | :----: | :-----: | :------: |
| name       | Name of the shard.                       | string |         |   yes    |
| stream_arn | The data stream to use for this consumer | string |         |   yes    |
