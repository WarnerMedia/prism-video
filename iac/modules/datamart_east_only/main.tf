# main.tf
data "aws_s3_bucket" "kda_east" {
  bucket = "${var.app}-useast1-kda"
}

data "aws_s3_bucket" "lambda_east" {
  bucket = "${var.app}-useast1-lambda"
}

module "datamart_destination_east_only" {
  source = "../datamart_destination_east_only"
  providers = {
    aws = aws
  }
  app                           = var.app
  internal                      = var.internal
  kpl_port                      = var.kpl_port
  log_level                     = var.log_level
  saml_role                     = var.saml_role
  tags                          = var.tags
  kds_raw_shard_count           = var.kds_raw_shard_count_us_east_1
  kds_agg_shard_count           = var.kds_agg_shard_count_us_east_1
  environment                   = var.environment_us_east_1
  region                        = var.region_us_east_1
  vpc                           = var.vpc_us_east_1
  agg_target_bucket_name        = var.agg_target_bucket_name_us_east_1
  private_subnets               = var.private_subnets_us_east_1
  public_subnets                = var.public_subnets_us_east_1
  kda_agg_parallelism           = var.kda_agg_parallelism_us_east_1
  kda_agg_parallelism_per_kpu   = var.kda_agg_parallelism_per_kpu_us_east_1
  stream_position_raw           = var.stream_position_raw
  kda_agg_jar_name              = var.kda_agg_jar_name
  firehose_agg_buffer_interval  = var.firehose_agg_buffer_interval
  firehose_agg_buffer_size      = var.firehose_agg_buffer_size
  firehose_sess_buffer_interval = var.firehose_sess_buffer_interval
  firehose_sess_buffer_size     = var.firehose_sess_buffer_size
  common_environment            = var.common_environment
  detailed_shard_level_metrics  = var.detailed_shard_level_metrics
  firehose_late_buffer_size     = var.firehose_late_buffer_size
  firehose_late_buffer_interval = var.firehose_late_buffer_interval
  late_arriving_secs            = var.late_arriving_secs
  video_session_ttl_secs        = var.video_session_ttl_secs
  late_target_bucket_name       = var.late_target_bucket_name_us_east_1
  sess_target_bucket_name       = var.sess_target_bucket_name_us_east_1
  kds_late_shard_count          = var.kds_late_shard_count_us_east_1
  kds_sess_shard_count          = var.kds_sess_shard_count_us_east_1

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

  late_arriving_lambda_env = {
    LOG_LEVEL        = "${var.log_level}"
    METRIC_NAMESPACE = "lambda-custom-metrics"
    METRIC_PREFIX    = "${local.nsuseast1}"
  }

  environment_properties_agg = {
    KINESIS_RAW_STREAM         = "${module.datamart_destination_east_only.kinesis_stream_name_raw}",
    KINESIS_AGG_STREAM         = "${module.datamart_destination_east_only.kinesis_stream_name_sess}"
    KINESIS_LATE_STREAM        = "${module.datamart_destination_east_only.kinesis_stream_name_late}"
    KINESIS_SESSION_STREAM     = "${module.datamart_destination_east_only.kinesis_stream_name_sess}"
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
