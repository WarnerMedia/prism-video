# ecr

## Function

- Create an ECR repository

## Module location(to give a frame of reference where it's used)

- Child module of base

## Contains the following terraform files

ecr.tf - creates an ecr repository.  
variables.tf - variables needed by this module.

## Variables

| Name                 | Description                                                                                                                                                                                                                                                                                                                 |  Type  |  Default  | Required |
| -------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----: | :-------: | :------: |
| app                  | Name of the bucket and ecr repo.                                                                                                                                                                                                                                                                                            | string |           |   yes    |
| tags                 | A map of the tags to apply to various resources. The required tags are: <br>+ `application`, name of the app <br>+ `environment`, the environment being created <br>+ `team`, team responsible for the application <br>+ `contact-email`, contact email for the _team_ <br>+ `customer`, who the application was create for |  map   |  `<map>`  |   yes    |
| image_tag_mutability | Whether the image tag is mutable                                                                                                                                                                                                                                                                                            | string | IMMUTABLE |   yes    |
