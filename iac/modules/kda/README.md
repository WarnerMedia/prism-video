# kda

## Function

- Create a Kinesis Data Analytics resource.

## Module location(to give a frame of reference where it's used)

- Child module of video_detail

## Contains the following terraform files

kda.tf - creates a kinesis data application using a flink 1.11 job.  
role-kda.tf - creates the roles needed by the kinesis data application.  
nsg-kda.tf - creates the security groups needed by the kinesis fata application.  
variables.tf - variables needed by this module.

## Variables

| Name                    | Description                                                                                                                                                                                                                                                                                                                 |  Type  | Default  | Required |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----: | :------: | :------: |
| name                    | Name of the KDA job.                                                                                                                                                                                                                                                                                                        | string |          |   yes    |
| tags                    | A map of the tags to apply to various resources. The required tags are: <br>+ `application`, name of the app <br>+ `environment`, the environment being created <br>+ `team`, team responsible for the application <br>+ `contact-email`, contact email for the _team_ <br>+ `customer`, who the application was create for |  map   | `<map>`  |   yes    |
| saml_role               | The SAML roles allowed to deploy.                                                                                                                                                                                                                                                                                           | string |          |   yes    |
| account_id              | The account id field is needed for saml role identifier                                                                                                                                                                                                                                                                     | string |          |   yes    |
| s3_kda_arn              | The ARN of the s3 bucket used by KDA to grab the jar file.                                                                                                                                                                                                                                                                  | string |          |   yes    |
| vpc                     | The vpc used by the KDA job                                                                                                                                                                                                                                                                                                 | string |          |   yes    |
| s3_object_key           | The name of the jar file to use.                                                                                                                                                                                                                                                                                            | string |          |   yes    |
| kms_resource_arns       | A list of the KMS ARN's needed for accessing KDS                                                                                                                                                                                                                                                                            |  map   | `<list>` |   yes    |
| kds_resource_arns       | A list of the KDS ARN's                                                                                                                                                                                                                                                                                                     |  map   | `<list>` |   yes    |
| environment_properties  | A map of the environment variables needed by the KDA job                                                                                                                                                                                                                                                                    |  map   | `<map>`  |   yes    |
| kda_parallelism         | The parallelism needed for this KDA job                                                                                                                                                                                                                                                                                     |  int   |          |   yes    |
| kda_parallelism_per_kpu | The parallelism per kpu needed for this KDA job                                                                                                                                                                                                                                                                             |  int   |          |   yes    |
| private_subnets         | The private subnets for the VPC                                                                                                                                                                                                                                                                                             | string |          |   yes    |
