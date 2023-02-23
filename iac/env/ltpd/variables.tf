/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The application's name
variable "app" {
}

variable "aws_profile" {
}


# Tags for the infrastructure
variable "tags" {
  type = map(string)
}

# Whether the application is available on the public internet,
# also will determine which subnets will be used (public or private)
variable "internal" {
  default = true
}

# The port the api will communicate with the kpl on
variable "kpl_port" {
}

# The verbosity of the logging.  debug, info, none
variable "log_level" {
}

# The SAML role to use for adding users to the ECR policy
variable "saml_role" {
}

# The common environment name
variable "common_environment" {
}

# Network configuration

# The VPC to use for the Fargate cluster
variable "vpc_us_east_1" {
}

# The private subnets, minimum of 2, that are a part of the VPC(s)
variable "private_subnets_us_east_1" {
}

# The public subnets, minimum of 2, that are a part of the VPC(s)
variable "public_subnets_us_east_1" {
}

# The AWS region to use for the dev environment's infrastructure
variable "region_us_east_1" {
  default = "us-east-1"
}

# The destination environment
variable "environment_us_east_1" {
}

locals {
  nsuseast1 = "${var.app}-${var.environment_us_east_1}"
}


variable "ecs_task_kpl_east_env" {
  type        = list(map(string))
  description = "environment varibale needed by the application"
}

# The destination buckets region
variable "destination_region" {
}

variable "s3_bucket_to_read_from" {}
