/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */


locals {
  ns      = "${var.app}-${var.environment}"
  nsunder = "${replace(var.app, "-", "_")}_${var.environment}"
}

# The application's name
variable "app" {
}

variable "aws_profile" {
}

variable "saml_role" {
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


# The common environment name
variable "common_environment" {
}

# Network configuration

# The VPC to use for the Fargate cluster
variable "vpc" {
}

# The private subnets, minimum of 2, that are a part of the VPC(s)
variable "private_subnets" {
}

# The public subnets, minimum of 2, that are a part of the VPC(s)
variable "public_subnets" {
}

# The AWS region to use for the dev environment's infrastructure
variable "region" {
}

# The destination environment
variable "environment" {
}


# reader
variable "ecs_autoscale_min_instances_reader" {
  default = "0"
}

variable "ecs_autoscale_max_instances_reader" {
  default = "1"
}

variable "container_port_reader" {
  default = "8087"
}

variable "container_name_reader" {
  default = "reader"
}

# loader
variable "ecs_autoscale_min_instances_loader" {
  default = "1"
}

variable "ecs_autoscale_max_instances_loader" {
  default = "1"
}

variable "container_port_loader" {
  default = "8088"
}

variable "container_name_loader" {
  default = "loader"
}


variable "s3_bucket_to_read_from" {}

variable "ecs_task_kpl_env" {
}

# If the average CPU utilization over a minute drops to this threshold,
# the number of containers will be reduced (but not below ecs_autoscale_min_instances).
variable "ecs_as_cpu_low_threshold_per" {
  default = "20"
}

# If the average CPU utilization over a minute rises to this threshold,
# the number of containers will be increased (but not above ecs_autoscale_max_instances).
variable "ecs_as_cpu_high_threshold_per" {
  default = "70"
}
