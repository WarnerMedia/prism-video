# main.tf
data "aws_s3_bucket" "kda_east" {
  bucket = "${var.app}-useast1-kda"
}

data "aws_s3_bucket" "kda_west" {
  provider = aws.us-west-2

  bucket = "${var.app}-uswest2-kda"
}

data "aws_s3_bucket" "lambda_east" {
  bucket = "${var.app}-useast1-lambda"
}

data "aws_s3_bucket" "lambda_west" {
  provider = aws.us-west-2

  bucket = "${var.app}-uswest2-lambda"
}

module "destination" {
  source = "../video_destination"
  providers = {
    aws = aws
  }
  app                                          = var.app
  internal                                     = var.internal
  kpl_port                                     = var.kpl_port
  log_level                                    = var.log_level
  container_port_app                           = var.container_port_app
  health_check_app                             = var.health_check_app
  saml_role                                    = var.saml_role
  deregistration_delay                         = var.deregistration_delay
  tags                                         = var.tags
  route53_zone_id                              = data.aws_route53_zone.app.zone_id
  hosted_zone                                  = var.hosted_zone
  common_subdomain                             = var.common_subdomain
  kds_raw_shard_count                          = var.kds_raw_shard_count_us_east_1
  kds_agg_shard_count                          = var.kds_agg_shard_count_us_east_1
  kds_late_shard_count                         = var.kds_late_shard_count_us_east_1
  kds_sess_shard_count                         = var.kds_sess_shard_count_us_east_1
  environment                                  = var.environment_us_east_1
  region                                       = var.region_us_east_1
  vpc                                          = var.vpc_us_east_1
  raw_target_bucket_name                       = var.raw_target_bucket_name_us_east_1
  agg_target_bucket_name                       = var.agg_target_bucket_name_us_east_1
  late_target_bucket_name                      = var.late_target_bucket_name_us_east_1
  sess_target_bucket_name                      = var.sess_target_bucket_name_us_east_1
  private_subnets                              = var.private_subnets_us_east_1
  public_subnets                               = var.public_subnets_us_east_1
  ecs_autoscale_min_instances_app              = var.ecs_autoscale_min_instances_app_us_east_1
  ecs_autoscale_max_instances_app              = var.ecs_autoscale_max_instances_app_us_east_1
  kda_agg_parallelism                          = var.kda_agg_parallelism_us_east_1
  kda_agg_parallelism_per_kpu                  = var.kda_agg_parallelism_per_kpu_us_east_1
  stream_position_raw                          = var.stream_position_raw
  kda_agg_jar_name                             = var.kda_agg_jar_name
  ecs_task_kpl_env                             = var.ecs_task_kpl_east_env
  firehose_agg_buffer_interval                 = var.firehose_agg_buffer_interval
  firehose_agg_buffer_size                     = var.firehose_agg_buffer_size
  firehose_raw_buffer_interval                 = var.firehose_raw_buffer_interval
  firehose_raw_buffer_size                     = var.firehose_raw_buffer_size
  firehose_late_buffer_interval                = var.firehose_late_buffer_interval
  firehose_late_buffer_size                    = var.firehose_late_buffer_size
  firehose_sess_buffer_interval                = var.firehose_sess_buffer_interval
  firehose_sess_buffer_size                    = var.firehose_sess_buffer_size
  common_environment                           = var.common_environment
  source_raw_target_bucket_arn                 = module.source.source_raw_target_bucket_arn
  source_raw_target_bucket_kms_arn             = module.source.source_raw_target_bucket_kms_arn
  source_late_target_bucket_arn                = module.source.source_late_target_bucket_arn
  source_late_target_bucket_kms_arn            = module.source.source_late_target_bucket_kms_arn
  source_sess_target_bucket_arn                = module.source.source_sess_target_bucket_arn
  source_sess_target_bucket_kms_arn            = module.source.source_sess_target_bucket_kms_arn
  source_region                                = var.source_region
  ecs_as_cpu_high_threshold_per                = var.ecs_as_cpu_high_threshold_per
  num_of_containers_to_add_during_scaling      = var.num_of_containers_to_add_during_scaling
  num_of_containers_to_remove_during_scaledown = var.num_of_containers_to_remove_during_scaledown
  detailed_shard_level_metrics                 = var.detailed_shard_level_metrics
  timestream_magnetic_ret_pd_in_days           = var.timestream_magnetic_ret_pd_in_days
  timestream_memory_ret_pd_in_hours            = var.timestream_memory_ret_pd_in_hours
  ecs_task_kpl_dmt_env                         = var.ecs_task_kpl_dmt_east_env
  ecs_task_kpl_slpd_env                        = var.ecs_task_kpl_slpd_east_env
  east_loader_role_arn                         = var.east_loader_role_arn
  east_ecr_loader_arn                          = var.east_ecr_loader_arn
  east_ecr_loader_ltpd_arn                     = var.east_ecr_loader_ltpd_arn
  east_ecr_reader_ltpd_arn                     = var.east_ecr_reader_ltpd_arn
  snowflake_iam_user                           = var.snowflake_iam_user
  payload_display_on_error                     = var.payload_display_on_error
  payload_limit                                = var.payload_limit
  enable_encryption                            = var.enable_encryption
  ecs_autoscale_min_instances_loader           = var.ecs_autoscale_min_instances_loader
  test_without_kpl                             = var.test_without_kpl
  batch_size                                   = var.batch_size
  maximum_batching_window_in_seconds           = var.maximum_batching_window_in_seconds
  starting_position                            = var.starting_position
  maximum_retry_attempts                       = var.maximum_retry_attempts
  maximum_record_age_in_seconds                = var.maximum_record_age_in_seconds
  bisect_batch_on_function_error               = var.bisect_batch_on_function_error
  parallelization_factor                       = var.parallelization_factor

  kda-records-out-per-sec-agg-enabled  = var.kda-records-out-per-sec-agg-enabled
  kda-millis-behind-latest-agg-enabled = var.kda-millis-behind-latest-agg-enabled
  kda-last-checkpoint-dur-agg-enabled  = var.kda-last-checkpoint-dur-agg-enabled
  kda-last-checkpoint-size-agg-enabled = var.kda-last-checkpoint-size-agg-enabled

  too_many_requests_threshold               = var.too_many_requests_threshold_us_east_1
  too_many_5xx_response_threshold           = var.too_many_5xx_response_threshold_us_east_1
  high_response_time_threshold              = var.high_response_time_threshold_us_east_1
  high_running_task_count_threshold         = var.high_running_task_count_threshold_us_east_1
  high_cpu_utilization_threshold            = var.high_cpu_utilization_threshold_us_east_1
  high_memory_utilization_threshold         = var.high_memory_utilization_threshold_us_east_1
  high_raw_kds_putrecs_failedrecs_threshold = var.high_raw_kds_putrecs_failedrecs_threshold_us_east_1
  high_agg_kds_putrecs_failedrecs_threshold = var.high_agg_kds_putrecs_failedrecs_threshold_us_east_1
  high_raw_kpl_retries_threshold            = var.high_raw_kpl_retries_threshold_us_east_1
  high_agg_kpl_retries_threshold            = var.high_agg_kpl_retries_threshold_us_east_1
  kda_records_out_per_sec_agg_threshold     = var.kda_records_out_per_sec_agg_threshold_us_east_1
  kda_millis_behind_latest_agg_threshold    = var.kda_millis_behind_latest_agg_threshold_us_east_1
  kda_last_checkpoint_dur_agg_threshold     = var.kda_last_checkpoint_dur_agg_threshold_us_east_1
  kda_last_checkpoint_size_agg_threshold    = var.kda_last_checkpoint_size_agg_threshold_us_east_1
  kda_heap_memory_util_agg_threshold        = var.kda_heap_memory_util_agg_threshold_us_east_1
  kda_cpu_util_agg_threshold                = var.kda_cpu_util_agg_threshold_us_east_1
  kda_threads_count_agg_threshold           = var.kda_threads_count_agg_threshold_us_east_1
  kda_max_exp_gc_time_agg_threshold         = var.kda_max_exp_gc_time_agg_threshold_us_east_1
  kda_max_exp_gc_cnt_agg_threshold          = var.kda_max_exp_gc_cnt_agg_threshold_us_east_1
  kda_min_exp_water_agg_threshold           = var.kda_min_exp_water_agg_threshold_us_east_1
  timestream_system_err_threshold           = var.timestream_system_err_threshold_us_east_1
  timestream_user_err_threshold             = var.timestream_user_err_threshold_us_east_1
  timestream_tbl_suc_req_latency_threshold  = var.timestream_tbl_suc_req_latency_threshold_us_east_1
  timestream_buf_error_threshold            = var.timestream_buf_error_threshold_us_east_1

  kds_timestream_buf_sess_lambda_env = {
    DATABASE_NAME     = "${module.destination.timestream_db_name}"
    TABLE_NAME        = "${module.destination.sessions_table_name}"
    LOG_LEVEL         = "${var.log_level}"
    METRIC_NAMESPACE  = "lambda-custom-metrics"
    METRIC_PREFIX     = "${local.nsuseast1}"
    TIMESTREAM_REGION = "${var.destination_region}"
  }

  late_arriving_lambda_env = {
    LOG_LEVEL        = "${var.log_level}"
    METRIC_NAMESPACE = "lambda-custom-metrics"
    METRIC_PREFIX    = "${local.nsuseast1}"
  }

  environment_properties_agg = {
    KINESIS_RAW_STREAM         = "${module.destination.kinesis_stream_name_raw}",
    KINESIS_AGG_STREAM         = "${module.destination.kinesis_stream_name_sess}"
    KINESIS_LATE_STREAM        = "${module.destination.kinesis_stream_name_late}"
    KINESIS_SESSION_STREAM     = "${module.destination.kinesis_stream_name_sess}"
    KINESIS_REGION             = "${var.destination_region}"
    STREAM_POSITION            = "${var.stream_position_raw}"
    ENABLE_EFO                 = "${var.kda_use_efo}"
    KDA_LATE_ARRIVING_SECS     = "${var.late_arriving_secs}"
    KDA_VIDEO_SESSION_TTL_SECS = "${var.video_session_ttl_secs}"
    KDA_STATE_TTL_SECS         = "${var.state_ttl_secs}"
  }
  kda_bucket_name    = data.aws_s3_bucket.kda_east.id
  kda_bucket_arn     = data.aws_s3_bucket.kda_east.arn
  kda_bucket_kms_arn = var.kda_bucket_kms_arn_us_east_1

  lambda_bucket_name    = data.aws_s3_bucket.lambda_east.id
  lambda_bucket_arn     = data.aws_s3_bucket.lambda_east.arn
  lambda_bucket_kms_arn = var.lambda_bucket_kms_arn_us_east_1
}

module "source" {
  source = "../video_source"
  providers = {
    aws = aws.us-west-2
  }
  app                                          = var.app
  internal                                     = var.internal
  kpl_port                                     = var.kpl_port
  log_level                                    = var.log_level
  container_port_app                           = var.container_port_app
  health_check_app                             = var.health_check_app
  saml_role                                    = var.saml_role
  deregistration_delay                         = var.deregistration_delay
  tags                                         = var.tags
  route53_zone_id                              = data.aws_route53_zone.app.zone_id
  hosted_zone                                  = var.hosted_zone
  common_subdomain                             = var.common_subdomain
  kds_raw_shard_count                          = var.kds_raw_shard_count_us_west_2
  kds_agg_shard_count                          = var.kds_agg_shard_count_us_west_2
  kds_late_shard_count                         = var.kds_late_shard_count_us_west_2
  kds_sess_shard_count                         = var.kds_sess_shard_count_us_west_2
  environment                                  = var.environment_us_west_2
  region                                       = var.region_us_west_2
  vpc                                          = var.vpc_us_west_2
  raw_target_bucket_name                       = var.raw_target_bucket_name_us_west_2
  agg_target_bucket_name                       = var.agg_target_bucket_name_us_west_2
  late_target_bucket_name                      = var.late_target_bucket_name_us_west_2
  sess_target_bucket_name                      = var.sess_target_bucket_name_us_west_2
  private_subnets                              = var.private_subnets_us_west_2
  public_subnets                               = var.public_subnets_us_west_2
  ecs_autoscale_min_instances_app              = var.ecs_autoscale_min_instances_app_us_west_2
  ecs_autoscale_max_instances_app              = var.ecs_autoscale_max_instances_app_us_west_2
  kda_agg_parallelism                          = var.kda_agg_parallelism_us_west_2
  kda_agg_parallelism_per_kpu                  = var.kda_agg_parallelism_per_kpu_us_west_2
  stream_position_raw                          = var.stream_position_raw
  kda_agg_jar_name                             = var.kda_agg_jar_name
  ecs_task_kpl_env                             = var.ecs_task_kpl_west_env
  firehose_agg_buffer_interval                 = var.firehose_agg_buffer_interval
  firehose_agg_buffer_size                     = var.firehose_agg_buffer_size
  firehose_raw_buffer_interval                 = var.firehose_raw_buffer_interval
  firehose_raw_buffer_size                     = var.firehose_raw_buffer_size
  firehose_late_buffer_interval                = var.firehose_late_buffer_interval
  firehose_late_buffer_size                    = var.firehose_late_buffer_size
  firehose_sess_buffer_interval                = var.firehose_sess_buffer_interval
  firehose_sess_buffer_size                    = var.firehose_sess_buffer_size
  common_environment                           = var.common_environment
  destination_raw_target_bucket_arn            = module.destination.destination_raw_target_bucket_arn
  destination_raw_target_bucket_kms_arn        = module.destination.destination_raw_target_bucket_kms_arn
  destination_late_target_bucket_arn           = module.destination.destination_late_target_bucket_arn
  destination_late_target_bucket_kms_arn       = module.destination.destination_late_target_bucket_kms_arn
  destination_sess_target_bucket_arn           = module.destination.destination_sess_target_bucket_arn
  destination_sess_target_bucket_kms_arn       = module.destination.destination_sess_target_bucket_kms_arn
  destination_region                           = var.destination_region
  ecs_as_cpu_high_threshold_per                = var.ecs_as_cpu_high_threshold_per
  num_of_containers_to_add_during_scaling      = var.num_of_containers_to_add_during_scaling
  num_of_containers_to_remove_during_scaledown = var.num_of_containers_to_remove_during_scaledown
  detailed_shard_level_metrics                 = var.detailed_shard_level_metrics
  timestream_magnetic_ret_pd_in_days           = var.timestream_magnetic_ret_pd_in_days
  timestream_memory_ret_pd_in_hours            = var.timestream_memory_ret_pd_in_hours
  west_loader_role_arn                         = var.west_loader_role_arn
  west_ecr_loader_arn                          = var.west_ecr_loader_arn
  west_ecr_loader_ltpd_arn                     = var.west_ecr_loader_ltpd_arn
  west_ecr_reader_ltpd_arn                     = var.west_ecr_reader_ltpd_arn
  payload_display_on_error                     = var.payload_display_on_error
  payload_limit                                = var.payload_limit
  enable_encryption                            = var.enable_encryption
  batch_size                                   = var.batch_size
  maximum_batching_window_in_seconds           = var.maximum_batching_window_in_seconds
  starting_position                            = var.starting_position
  maximum_retry_attempts                       = var.maximum_retry_attempts
  maximum_record_age_in_seconds                = var.maximum_record_age_in_seconds
  bisect_batch_on_function_error               = var.bisect_batch_on_function_error
  parallelization_factor                       = var.parallelization_factor

  kda-records-out-per-sec-agg-enabled  = var.kda-records-out-per-sec-agg-enabled
  kda-millis-behind-latest-agg-enabled = var.kda-millis-behind-latest-agg-enabled
  kda-last-checkpoint-dur-agg-enabled  = var.kda-last-checkpoint-dur-agg-enabled
  kda-last-checkpoint-size-agg-enabled = var.kda-last-checkpoint-size-agg-enabled

  too_many_requests_threshold               = var.too_many_requests_threshold_us_west_2
  too_many_5xx_response_threshold           = var.too_many_5xx_response_threshold_us_west_2
  high_response_time_threshold              = var.high_response_time_threshold_us_west_2
  high_running_task_count_threshold         = var.high_running_task_count_threshold_us_west_2
  high_cpu_utilization_threshold            = var.high_cpu_utilization_threshold_us_west_2
  high_memory_utilization_threshold         = var.high_memory_utilization_threshold_us_west_2
  high_raw_kds_putrecs_failedrecs_threshold = var.high_raw_kds_putrecs_failedrecs_threshold_us_west_2
  high_agg_kds_putrecs_failedrecs_threshold = var.high_agg_kds_putrecs_failedrecs_threshold_us_west_2
  high_raw_kpl_retries_threshold            = var.high_raw_kpl_retries_threshold_us_west_2
  high_agg_kpl_retries_threshold            = var.high_agg_kpl_retries_threshold_us_west_2
  kda_records_out_per_sec_agg_threshold     = var.kda_records_out_per_sec_agg_threshold_us_west_2
  kda_millis_behind_latest_agg_threshold    = var.kda_millis_behind_latest_agg_threshold_us_west_2
  kda_last_checkpoint_dur_agg_threshold     = var.kda_last_checkpoint_dur_agg_threshold_us_west_2
  kda_last_checkpoint_size_agg_threshold    = var.kda_last_checkpoint_size_agg_threshold_us_west_2
  kda_heap_memory_util_agg_threshold        = var.kda_heap_memory_util_agg_threshold_us_west_2
  kda_cpu_util_agg_threshold                = var.kda_cpu_util_agg_threshold_us_west_2
  kda_threads_count_agg_threshold           = var.kda_threads_count_agg_threshold_us_west_2
  kda_max_exp_gc_time_agg_threshold         = var.kda_max_exp_gc_time_agg_threshold_us_west_2
  kda_max_exp_gc_cnt_agg_threshold          = var.kda_max_exp_gc_cnt_agg_threshold_us_west_2
  kda_min_exp_water_agg_threshold           = var.kda_min_exp_water_agg_threshold_us_west_2
  timestream_system_err_threshold           = var.timestream_system_err_threshold_us_west_2
  timestream_user_err_threshold             = var.timestream_user_err_threshold_us_west_2
  timestream_tbl_suc_req_latency_threshold  = var.timestream_tbl_suc_req_latency_threshold_us_west_2
  timestream_buf_error_threshold            = var.timestream_buf_error_threshold_us_west_2
  kds_timestream_buf_sess_lambda_env = {
    DATABASE_NAME     = "${module.destination.timestream_db_name}"
    TABLE_NAME        = "${module.destination.sessions_table_name}"
    LOG_LEVEL         = "${var.log_level}"
    METRIC_NAMESPACE  = "lambda-custom-metrics"
    METRIC_PREFIX     = "${local.nsuswest2}"
    TIMESTREAM_REGION = "${var.destination_region}"
  }

  environment_properties_agg = {
    KINESIS_RAW_STREAM         = "${module.source.kinesis_stream_name_raw}",
    KINESIS_AGG_STREAM         = "${module.source.kinesis_stream_name_sess}"
    KINESIS_LATE_STREAM        = "${module.source.kinesis_stream_name_late}"
    KINESIS_SESSION_STREAM     = "${module.source.kinesis_stream_name_sess}"
    KINESIS_REGION             = "${var.source_region}"
    STREAM_POSITION            = "${var.stream_position_raw}"
    ENABLE_EFO                 = "${var.kda_use_efo}"
    KDA_LATE_ARRIVING_SECS     = "${var.late_arriving_secs}"
    KDA_VIDEO_SESSION_TTL_SECS = "${var.video_session_ttl_secs}"
    KDA_STATE_TTL_SECS         = "${var.state_ttl_secs}"
  }

  kda_bucket_name    = data.aws_s3_bucket.kda_west.id
  kda_bucket_arn     = data.aws_s3_bucket.kda_west.arn
  kda_bucket_kms_arn = var.kda_bucket_kms_arn_us_west_2

  lambda_bucket_name    = data.aws_s3_bucket.lambda_west.id
  lambda_bucket_arn     = data.aws_s3_bucket.lambda_west.arn
  lambda_bucket_kms_arn = var.lambda_bucket_kms_arn_us_west_2
}

output "source_timestream_db_name" {
  value = module.source.timestream_db_name
}
output "source_timestream_session_name" {
  value = module.source.sessions_table_name
}
output "source_timestream_kms_arn" {
  value = module.source.timestream_kms_arn
}
output "source_cluster_name" {
  value = module.source.cluster_name
}

output "destination_timestream_db_name" {
  value = module.destination.timestream_db_name
}
output "destination_timestream_session_name" {
  value = module.destination.sessions_table_name
}
output "destination_timestream_kms_arn" {
  value = module.destination.timestream_kms_arn
}
output "destination_cluster_name" {
  value = module.destination.cluster_name
}

