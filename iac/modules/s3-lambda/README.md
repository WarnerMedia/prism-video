# s3-lambda

## Function

- Creates an s3 bucket for lambda zip deployments

## Contains the following terraform files

s3-lambda.tf - creates an s3 bucket with kms encryption
variables.tf - variables needed by this module.

## Variables

| Name | Description                                                                                                                                                                                                                                                                                                                 |  Type  | Default | Required |
| ---- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----: | :-----: | :------: |
| app  | Prefix name of the bucket.                                                                                                                                                                                                                                                                                                  | string |         |   yes    |
| tags | A map of the tags to apply to various resources. The required tags are: <br>+ `application`, name of the app <br>+ `environment`, the environment being created <br>+ `team`, team responsible for the application <br>+ `contact-email`, contact email for the _team_ <br>+ `customer`, who the application was create for |  map   | `<map>` |   yes    |
