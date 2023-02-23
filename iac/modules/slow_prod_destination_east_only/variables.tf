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

# Tags for the infrastructure
variable "tags" {
  type = map(string)
}

# The port the load balancer will listen on
variable "lb_port" {
  default = "80"
}

# The load balancer protocol
variable "lb_protocol" {
  default = "HTTP"
}

variable "lb_access_logs_expiration_days" {
  default = "3"
}

variable "health_check_interval" {
  default = "30"
}

# How long to wait for the response on the health check path
variable "health_check_timeout" {
  default = "10"
}

# What HTTP response code to listen for
variable "health_check_matcher" {
  default = "200"
}

variable "logs_retention_in_days" {
  type        = number
  default     = 90
  description = "Specifies the number of days you want to retain log events"
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

# the agg target bucket
variable "agg_target_bucket_name" {
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

#kds agg

variable "kds_agg_shard_count" {
}

variable "firehose_agg_buffer_size" {
}

variable "firehose_agg_buffer_interval" {
}

#kds raw

variable "kds_raw_shard_count" {
}

#kda

variable "kda_agg_parallelism" {
}

variable "kda_agg_parallelism_per_kpu" {
}

variable "stream_position_raw" {
}

variable "environment_properties_agg" {
  type = map(string)
}

# thresholds for alarms
variable "high_agg_kds_putrecs_failedrecs_threshold" {}
variable "high_raw_kpl_retries_threshold" {}
variable "high_agg_kpl_retries_threshold" {}
variable "kda_records_out_per_sec_agg_threshold" {}
variable "kda_millis_behind_latest_agg_threshold" {}
variable "kda_last_checkpoint_dur_agg_threshold" {}
variable "kda_last_checkpoint_size_agg_threshold" {}
variable "kda_heap_memory_util_agg_threshold" {}
variable "kda_cpu_util_agg_threshold" {}
variable "kda_threads_count_agg_threshold" {}
variable "kda_max_exp_gc_time_agg_threshold" {}
variable "kda_max_exp_gc_cnt_agg_threshold" {}
variable "kda_min_exp_water_agg_threshold" {}
variable "timestream_system_err_threshold" {}
variable "timestream_user_err_threshold" {}
variable "timestream_tbl_suc_req_latency_threshold" {}

variable "kda_bucket_name" {}
variable "kda_bucket_arn" {}
variable "kda_bucket_kms_arn" {}

variable "kda_agg_jar_name" {}


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

variable "detailed_shard_level_metrics" {
  type        = list(string)
  description = "shard level metrics"
}

variable "timestream_magnetic_ret_pd_in_days" {}
variable "timestream_memory_ret_pd_in_hours" {}

# the late target bucket for the destination
variable "late_target_bucket_name" {
}

variable "kds_late_shard_count" {
}

variable "firehose_late_buffer_size" {
}

variable "firehose_late_buffer_interval" {
}

variable "late_arriving_secs" {}
variable "video_session_ttl_secs" {}

variable "lambda_bucket_name" {}
variable "lambda_bucket_arn" {}
variable "lambda_bucket_kms_arn" {}

variable "late_arriving_lambda_env" {
  type = map(string)
}

variable "timestream_buf_error_threshold" {}

variable "batch_size" {}                         # "100"
variable "maximum_batching_window_in_seconds" {} # "5"
variable "starting_position" {}                  # "LATEST"
variable "maximum_retry_attempts" {}             # "5"
variable "maximum_record_age_in_seconds" {}      # "-1"
variable "bisect_batch_on_function_error" {}     # "true"
variable "parallelization_factor" {}             # "10"

variable "firehose_sess_buffer_size" {}
variable "firehose_sess_buffer_interval" {}
variable "kds_sess_shard_count" {}
variable "sess_target_bucket_name" {}
variable "kds_timestream_buf_sess_lambda_env" {}
