/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The application's name
variable "app" {
}

# The AWS region to use for the environment's infrastructure
variable "region" {
}

# Tags for the infrastructure
variable "tags" {
  type = map(string)
}

# The environment that is being built
variable "environment" {
}

# The port the api will communicate with the kpl on
variable "kpl_port" {
}

# The verbosity of the logging.  debug, info, none
variable "log_level" {
}
# The port the load balancer will listen on
variable "lb_port" {
  default = "80"
}

# The load balancer protocol
variable "lb_protocol" {
  default = "HTTP"
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

variable "logs_retention_in_days" {
  type        = number
  default     = 90
  description = "Specifies the number of days you want to retain log events"
}

locals {
  ns = "${var.app}-${var.environment}"
}

# these are passed in from a parent module
# The parent module must create an S3 bucket with KMS and pass the buckets arn via s3_target_bucket_arn and the buckets id via s3_target_bucket_id.  
# The arn of the KMS key for the bucket must be passed in via s3_target_bucket_kms_arn
variable "raw_target_bucket_arn" {
}

variable "sess_target_bucket_arn" {
}

variable "late_target_bucket_arn" {
}

variable "raw_target_kms_arn" {
}

variable "sess_target_kms_arn" {
}

variable "late_target_kms_arn" {
}

variable "raw_target_bucket_id" {
}

# these are passed in from a parent module
# The parent module must have already created the common_subdomain(ex. dev.mydomain.io) in the hosted_zone(mydomain.io).  
# The route53_zone_id is the zone id of the hosted_zone.
variable "route53_zone_id" {
}

variable "hosted_zone" {
}

variable "common_subdomain" {
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

variable "num_of_containers_to_add_during_scaling" {
  default = "10"
}

variable "num_of_containers_to_remove_during_scaledown" {
  default = "-1"
}

# app

variable "container_name_app" {
  default = "app"
}

variable "container_port_app" {
}

variable "health_check_app" {
}

variable "ecs_autoscale_min_instances_app" {
  default = "1"
}

variable "ecs_autoscale_max_instances_app" {
  default = "2"
}

#kds

variable "kds_agg_shard_count" {
  type    = number
  default = 1
}

variable "kds_raw_shard_count" {
  type    = number
  default = 1
}

variable "kds_late_shard_count" {
  type    = number
  default = 1
}


# firehose 

variable "firehose_agg_buffer_size" {
  type    = number
  default = 8
}

variable "firehose_agg_buffer_interval" {
  type    = number
  default = 60
}

variable "firehose_raw_buffer_size" {
  type    = number
  default = 8
}

variable "firehose_raw_buffer_interval" {
  type    = number
  default = 60
}

variable "firehose_late_buffer_size" {
  type    = number
  default = 8
}

variable "firehose_late_buffer_interval" {
  type    = number
  default = 60
}

#kda

variable "kda_agg_parallelism" {
}

variable "kda_agg_parallelism_per_kpu" {
}

variable "ecs_task_kpl_env" {
}

variable "environment_properties_agg" {
  type = map(string)
}

variable "kda_bucket_name" {}
variable "kda_bucket_arn" {}
variable "kda_bucket_kms_arn" {}

variable "kda_agg_jar_name" {}

variable "lambda_bucket_name" {}
variable "lambda_bucket_arn" {}
variable "lambda_bucket_kms_arn" {}

variable "detailed_shard_level_metrics" {
  type        = list(string)
  description = "shard level metrics"
}

variable "timestream_magnetic_ret_pd_in_days" {}
variable "timestream_memory_ret_pd_in_hours" {}

variable "loader_role_arn" {}

variable "ecr_loader_arn" {}

variable "ecr_loader_ltpd_arn" {}

variable "ecr_reader_ltpd_arn" {}

variable "payload_display_on_error" {}

variable "payload_limit" {}

variable "enable_encryption" {}

variable "batch_size" {}                         # "100"
variable "maximum_batching_window_in_seconds" {} # "5"
variable "starting_position" {}                  # "LATEST"
variable "maximum_retry_attempts" {}             # "5"
variable "maximum_record_age_in_seconds" {}      # "-1"
variable "bisect_batch_on_function_error" {}     # "true"
variable "parallelization_factor" {}             # "10"

variable "kds_timestream_buf_sess_lambda_env" {}
variable "firehose_sess_buffer_size" {}
variable "firehose_sess_buffer_interval" {}
variable "kds_sess_shard_count" {}
