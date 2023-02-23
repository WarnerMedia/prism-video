/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The application's name
variable "app" {
}

variable "aws_profile" {
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

# the agg target bucket for the destination
variable "agg_target_bucket_name_us_east_1" {
}

locals {
  nsuseast1 = "${var.app}-${var.environment_us_east_1}"
}


#kds agg

variable "kds_agg_shard_count_us_east_1" {
}

variable "firehose_agg_buffer_size" {
}

variable "firehose_agg_buffer_interval" {
}

#kds raw

variable "kds_raw_shard_count_us_east_1" {
}

#kda

variable "kda_agg_parallelism_us_east_1" {
}

variable "kda_agg_parallelism_per_kpu_us_east_1" {
}

variable "stream_position_raw" {
}

# The destination buckets region
variable "destination_region" {
}

# thresholds for us_east_1 alarms
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

variable "kda_bucket_kms_arn_us_east_1" {}

variable "kda_agg_jar_name" {}

variable "shard_use_adaptive_reads" {}
variable "shard_getrecords_interval_millis" {}
variable "shard_getrecords_max" {}
variable "kda_use_efo" {}
variable "detailed_shard_level_metrics" {
  type        = list(string)
  description = "shard level metrics"
}

# the late target bucket for the destination
variable "late_target_bucket_name_us_east_1" {
}

variable "kds_late_shard_count_us_east_1" {
}

variable "firehose_late_buffer_size" {
}

variable "firehose_late_buffer_interval" {
}

variable "late_arriving_secs" {}

variable "lambda_bucket_kms_arn_us_east_1" {}

variable "video_session_ttl_secs" {}

variable "state_ttl_secs" {}

variable "sess_target_bucket_name_us_east_1" {}
variable "kds_sess_shard_count_us_east_1" {}
variable "firehose_sess_buffer_size" {}
variable "firehose_sess_buffer_interval" {}
