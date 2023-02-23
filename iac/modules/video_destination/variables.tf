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

# The SAML role to use for adding users to the ECR policy
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


variable "deregistration_delay" {
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

# the raw target bucket
variable "raw_target_bucket_name" {
}

# the agg target bucket
variable "agg_target_bucket_name" {
}

# the late target bucket
variable "late_target_bucket_name" {
}

variable "hosted_zone" {
}

variable "common_subdomain" {
}

variable "route53_zone_id" {
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

variable "ecs_as_cpu_low_threshold_per" {
  default = "20"
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

variable "firehose_raw_buffer_size" {
}

variable "firehose_raw_buffer_interval" {
}

#kds late

variable "kds_late_shard_count" {
}

variable "firehose_late_buffer_size" {
}

variable "firehose_late_buffer_interval" {
}


#kda

variable "kda_agg_parallelism" {
}

variable "kda_agg_parallelism_per_kpu" {
}

variable "stream_position_raw" {
}

variable "ecs_task_kpl_env" {
}

#source s3 info
variable "source_raw_target_bucket_arn" {
}

variable "source_raw_target_bucket_kms_arn" {
}

variable "source_late_target_bucket_arn" {
}

variable "source_late_target_bucket_kms_arn" {
}

variable "source_sess_target_bucket_arn" {
}

variable "source_sess_target_bucket_kms_arn" {
}


# The source buckets region
variable "source_region" {
}

variable "environment_properties_agg" {
  type = map(string)
}

# thresholds for alarms
variable "too_many_requests_threshold" {}
variable "too_many_5xx_response_threshold" {}
variable "high_response_time_threshold" {}
variable "high_running_task_count_threshold" {}
variable "high_cpu_utilization_threshold" {}
variable "high_memory_utilization_threshold" {}
variable "high_raw_kds_putrecs_failedrecs_threshold" {}
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

variable "lambda_bucket_name" {}
variable "lambda_bucket_arn" {}
variable "lambda_bucket_kms_arn" {}

variable "ecs_as_cpu_high_threshold_per" {
  default = "70"
}

variable "num_of_containers_to_add_during_scaling" {
  default = "10"
}

variable "num_of_containers_to_remove_during_scaledown" {
  default = "-1"
}

variable "detailed_shard_level_metrics" {
  type        = list(string)
  description = "shard level metrics"
}

variable "timestream_magnetic_ret_pd_in_days" {}
variable "timestream_memory_ret_pd_in_hours" {}

variable "late_arriving_lambda_env" {
  type = map(string)
}

variable "ecs_task_kpl_dmt_env" {
  type = list(map(string))
}

variable "ecs_task_kpl_slpd_env" {
  type = list(map(string))
}

variable "east_ecr_loader_arn" {}

variable "east_ecr_loader_ltpd_arn" {}

variable "east_ecr_reader_ltpd_arn" {}

variable "east_loader_role_arn" {}

variable "snowflake_iam_user" {}

variable "payload_display_on_error" {}

variable "payload_limit" {}

variable "enable_encryption" {}

variable "test_without_kpl" {}

variable "timestream_buf_error_threshold" {}

variable "batch_size" {}                         # "100"
variable "maximum_batching_window_in_seconds" {} # "5"
variable "starting_position" {}                  # "LATEST"
variable "maximum_retry_attempts" {}             # "5"
variable "maximum_record_age_in_seconds" {}      # "-1"
variable "bisect_batch_on_function_error" {}     # "true"
variable "parallelization_factor" {}             # "10"

variable "kda-records-out-per-sec-agg-enabled" {}
variable "kda-millis-behind-latest-agg-enabled" {}
variable "kda-last-checkpoint-dur-agg-enabled" {}
variable "kda-last-checkpoint-size-agg-enabled" {}

variable "sess_target_bucket_name" {}
variable "kds_sess_shard_count" {}
variable "kds_timestream_buf_sess_lambda_env" {}
variable "firehose_sess_buffer_size" {}
variable "firehose_sess_buffer_interval" {}
