# kds

## Function

- Create a Provisioned Kinesis Data Stream resource.

## Module location(to give a frame of reference where it's used)

- Child module of video_detail

## Contains the following terraform files

kds.tf - creates a kinesis data stream.  
variables.tf - variables needed by this module.

## Variables

| Name            | Description                                                                                                                                                                                                                                                                                                                 |  Type  | Default | Required |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----: | :-----: | :------: |
| name            | Name of the shard.                                                                                                                                                                                                                                                                                                          | string |         |   yes    |
| tags            | A map of the tags to apply to various resources. The required tags are: <br>+ `application`, name of the app <br>+ `environment`, the environment being created <br>+ `team`, team responsible for the application <br>+ `contact-email`, contact email for the _team_ <br>+ `customer`, who the application was create for |  map   | `<map>` |   yes    |
| kds_shard_count | The number of shards needed for this data stream                                                                                                                                                                                                                                                                            |  int   |         |   yes    |
