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

variable "deregistration_delay" {
}

# The common environment name
variable "common_environment" {
}

# Network configuration

# The VPC to use for the Fargate cluster
variable "vpc_us_east_1" {
}

variable "vpc_us_west_2" {
}

# The private subnets, minimum of 2, that are a part of the VPC(s)
variable "private_subnets_us_east_1" {
}

variable "private_subnets_us_west_2" {
}

# The public subnets, minimum of 2, that are a part of the VPC(s)
variable "public_subnets_us_east_1" {
}

variable "public_subnets_us_west_2" {
}

# The AWS region to use for the dev environment's infrastructure
variable "region_us_east_1" {
  default = "us-east-1"
}

variable "region_us_west_2" {
  default = "us-west-2"
}

# The destination environment
variable "environment_us_east_1" {
}

variable "environment_us_west_2" {
}

# the raw target bucket for the destination
variable "raw_target_bucket_name_us_east_1" {
}

variable "raw_target_bucket_name_us_west_2" {
}

# the agg target bucket for the destination
variable "agg_target_bucket_name_us_east_1" {
}

variable "agg_target_bucket_name_us_west_2" {
}

# the late target bucket for the destination
variable "late_target_bucket_name_us_east_1" {
}

variable "late_target_bucket_name_us_west_2" {
}

locals {
  nsuseast1 = "${var.app}-${var.environment_us_east_1}"
  nsuswest2 = "${var.app}-${var.environment_us_west_2}"
}

variable "hosted_zone" {
}

variable "common_subdomain" {
}

# app

variable "container_name_app" {
  default = "app"
}

variable "container_port_app" {
}

variable "health_check_app" {
}

variable "ecs_autoscale_min_instances_app_us_east_1" {
  default = "1"
}

variable "ecs_autoscale_max_instances_app_us_east_1" {
  default = "2"
}

variable "ecs_autoscale_min_instances_app_us_west_2" {
  default = "1"
}

variable "ecs_autoscale_max_instances_app_us_west_2" {
  default = "2"
}

#kds agg

variable "kds_agg_shard_count_us_east_1" {
}

variable "kds_agg_shard_count_us_west_2" {
}

variable "firehose_agg_buffer_size" {
}

variable "firehose_agg_buffer_interval" {
}

#kds raw

variable "kds_raw_shard_count_us_east_1" {
}

variable "kds_raw_shard_count_us_west_2" {
}

variable "firehose_raw_buffer_size" {
}

variable "firehose_raw_buffer_interval" {
}

#kds late

variable "kds_late_shard_count_us_east_1" {
}

variable "kds_late_shard_count_us_west_2" {
}

variable "firehose_late_buffer_size" {
}

variable "firehose_late_buffer_interval" {
}

#kda

variable "kda_agg_parallelism_us_east_1" {
}

variable "kda_agg_parallelism_per_kpu_us_east_1" {
}

variable "kda_agg_parallelism_us_west_2" {
}

variable "kda_agg_parallelism_per_kpu_us_west_2" {
}

variable "stream_position_raw" {
}

variable "ecs_task_kpl_east_env" {
  type        = list(map(string))
  description = "environment varibale needed by the application"
}

variable "ecs_task_kpl_west_env" {
  type        = list(map(string))
  description = "environment varibale needed by the application"
}

# The destination buckets region
variable "destination_region" {
}

# The source buckets region
variable "source_region" {
}

# thresholds for us_east_1 alarms
variable "too_many_requests_threshold_us_east_1" {}
variable "too_many_5xx_response_threshold_us_east_1" {}
variable "high_response_time_threshold_us_east_1" {}
variable "high_running_task_count_threshold_us_east_1" {}
variable "high_cpu_utilization_threshold_us_east_1" {}
variable "high_memory_utilization_threshold_us_east_1" {}
variable "high_raw_kds_putrecs_failedrecs_threshold_us_east_1" {}
variable "high_agg_kds_putrecs_failedrecs_threshold_us_east_1" {}
variable "high_raw_kpl_retries_threshold_us_east_1" {}
variable "high_agg_kpl_retries_threshold_us_east_1" {}
variable "kda_records_out_per_sec_agg_threshold_us_east_1" {}
variable "kda_millis_behind_latest_agg_threshold_us_east_1" {}
variable "kda_last_checkpoint_dur_agg_threshold_us_east_1" {}
variable "kda_last_checkpoint_size_agg_threshold_us_east_1" {}
variable "kda_heap_memory_util_agg_threshold_us_east_1" {}
variable "kda_cpu_util_agg_threshold_us_east_1" {}
variable "kda_threads_count_agg_threshold_us_east_1" {}
variable "kda_max_exp_gc_time_agg_threshold_us_east_1" {}
variable "kda_max_exp_gc_cnt_agg_threshold_us_east_1" {}
variable "kda_min_exp_water_agg_threshold_us_east_1" {}
variable "timestream_system_err_threshold_us_east_1" {}
variable "timestream_user_err_threshold_us_east_1" {}
variable "timestream_tbl_suc_req_latency_threshold_us_east_1" {}

# thresholds for us_west_2 alarms
variable "too_many_requests_threshold_us_west_2" {}
variable "too_many_5xx_response_threshold_us_west_2" {}
variable "high_response_time_threshold_us_west_2" {}
variable "high_running_task_count_threshold_us_west_2" {}
variable "high_cpu_utilization_threshold_us_west_2" {}
variable "high_memory_utilization_threshold_us_west_2" {}
variable "high_raw_kds_putrecs_failedrecs_threshold_us_west_2" {}
variable "high_agg_kds_putrecs_failedrecs_threshold_us_west_2" {}
variable "high_raw_kpl_retries_threshold_us_west_2" {}
variable "high_agg_kpl_retries_threshold_us_west_2" {}
variable "kda_records_out_per_sec_agg_threshold_us_west_2" {}
variable "kda_millis_behind_latest_agg_threshold_us_west_2" {}
variable "kda_last_checkpoint_dur_agg_threshold_us_west_2" {}
variable "kda_last_checkpoint_size_agg_threshold_us_west_2" {}
variable "kda_heap_memory_util_agg_threshold_us_west_2" {}
variable "kda_cpu_util_agg_threshold_us_west_2" {}
variable "kda_threads_count_agg_threshold_us_west_2" {}
variable "kda_max_exp_gc_time_agg_threshold_us_west_2" {}
variable "kda_max_exp_gc_cnt_agg_threshold_us_west_2" {}
variable "kda_min_exp_water_agg_threshold_us_west_2" {}
variable "timestream_system_err_threshold_us_west_2" {}
variable "timestream_user_err_threshold_us_west_2" {}
variable "timestream_tbl_suc_req_latency_threshold_us_west_2" {}

variable "kda_bucket_kms_arn_us_east_1" {}
variable "kda_bucket_kms_arn_us_west_2" {}

variable "kda_agg_jar_name" {}

variable "timestream_ingest_batch_size" {}
variable "shard_use_adaptive_reads" {}
variable "shard_getrecords_interval_millis" {}
variable "shard_getrecords_max" {}
variable "kda_use_efo" {}

variable "ecs_as_cpu_high_threshold_per" {}
variable "num_of_containers_to_add_during_scaling" {}
variable "num_of_containers_to_remove_during_scaledown" {}

variable "detailed_shard_level_metrics" {
  type        = list(string)
  description = "shard level metrics"
}

variable "timestream_magnetic_ret_pd_in_days" {}
variable "timestream_memory_ret_pd_in_hours" {}

variable "late_arriving_secs" {}

variable "lambda_bucket_kms_arn_us_east_1" {}
variable "lambda_bucket_kms_arn_us_west_2" {}


variable "ecs_task_kpl_dmt_east_env" {
  type = list(map(string))
}

variable "ecs_task_kpl_slpd_east_env" {
  type = list(map(string))
}

variable "east_ecr_loader_arn" {}
variable "west_ecr_loader_arn" {}

variable "east_ecr_loader_ltpd_arn" {}
variable "west_ecr_loader_ltpd_arn" {}

variable "east_ecr_reader_ltpd_arn" {}
variable "west_ecr_reader_ltpd_arn" {}

variable "east_loader_role_arn" {}
variable "west_loader_role_arn" {}

variable "video_session_ttl_secs" {}

variable "snowflake_iam_user" {}

variable "payload_display_on_error" {}

variable "payload_limit" {}

variable "enable_encryption" {}

variable "ecs_autoscale_min_instances_loader" {}

variable "test_without_kpl" {}

variable "state_ttl_secs" {}

variable "timestream_buf_error_threshold_us_east_1" {}
variable "timestream_buf_error_threshold_us_west_2" {}

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

variable "sess_target_bucket_name_us_east_1" {}
variable "sess_target_bucket_name_us_west_2" {}
variable "kds_sess_shard_count_us_east_1" {}
variable "kds_sess_shard_count_us_west_2" {}
variable "firehose_sess_buffer_size" {}
variable "firehose_sess_buffer_interval" {}
