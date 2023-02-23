# main.tf
module "datamart_east_only" {
  source                                              = "../../modules/datamart_east_only"
  app                                                 = var.app
  aws_profile                                         = var.aws_profile
  internal                                            = var.internal
  kpl_port                                            = var.kpl_port
  log_level                                           = var.log_level
  saml_role                                           = var.saml_role
  firehose_agg_buffer_size                            = var.firehose_agg_buffer_size
  firehose_agg_buffer_interval                        = var.firehose_agg_buffer_interval
  firehose_sess_buffer_size                           = var.firehose_sess_buffer_size
  firehose_sess_buffer_interval                       = var.firehose_sess_buffer_interval
  tags                                                = var.tags
  common_environment                                  = var.common_environment
  destination_region                                  = var.destination_region
  stream_position_raw                                 = var.stream_position_raw
  kda_agg_jar_name                                    = var.kda_agg_jar_name
  shard_use_adaptive_reads                            = var.shard_use_adaptive_reads
  shard_getrecords_interval_millis                    = var.shard_getrecords_interval_millis
  shard_getrecords_max                                = var.shard_getrecords_max
  kda_use_efo                                         = var.kda_use_efo
  detailed_shard_level_metrics                        = var.detailed_shard_level_metrics
  late_arriving_secs                                  = var.late_arriving_secs
  video_session_ttl_secs                              = var.video_session_ttl_secs
  state_ttl_secs                                      = var.state_ttl_secs
  environment_us_east_1                               = var.environment_us_east_1
  region_us_east_1                                    = var.region_us_east_1
  vpc_us_east_1                                       = var.vpc_us_east_1
  private_subnets_us_east_1                           = var.private_subnets_us_east_1
  public_subnets_us_east_1                            = var.public_subnets_us_east_1
  agg_target_bucket_name_us_east_1                    = var.agg_target_bucket_name_us_east_1
  sess_target_bucket_name_us_east_1                   = var.sess_target_bucket_name_us_east_1
  kds_raw_shard_count_us_east_1                       = var.kds_raw_shard_count_us_east_1
  kds_agg_shard_count_us_east_1                       = var.kds_agg_shard_count_us_east_1
  kds_sess_shard_count_us_east_1                      = var.kds_sess_shard_count_us_east_1
  kda_agg_parallelism_us_east_1                       = var.kda_agg_parallelism_us_east_1
  kda_agg_parallelism_per_kpu_us_east_1               = var.kda_agg_parallelism_per_kpu_us_east_1
  firehose_late_buffer_size                           = var.firehose_late_buffer_size
  firehose_late_buffer_interval                       = var.firehose_late_buffer_interval
  late_target_bucket_name_us_east_1                   = var.late_target_bucket_name_us_east_1
  kds_late_shard_count_us_east_1                      = var.kds_late_shard_count_us_east_1
  high_agg_kds_putrecs_failedrecs_threshold_us_east_1 = var.high_agg_kds_putrecs_failedrecs_threshold_us_east_1
  high_raw_kpl_retries_threshold_us_east_1            = var.high_raw_kpl_retries_threshold_us_east_1
  high_agg_kpl_retries_threshold_us_east_1            = var.high_agg_kpl_retries_threshold_us_east_1
  kda_records_out_per_sec_agg_threshold_us_east_1     = var.kda_records_out_per_sec_agg_threshold_us_east_1
  kda_millis_behind_latest_agg_threshold_us_east_1    = var.kda_millis_behind_latest_agg_threshold_us_east_1
  kda_last_checkpoint_dur_agg_threshold_us_east_1     = var.kda_last_checkpoint_dur_agg_threshold_us_east_1
  kda_last_checkpoint_size_agg_threshold_us_east_1    = var.kda_last_checkpoint_size_agg_threshold_us_east_1
  kda_heap_memory_util_agg_threshold_us_east_1        = var.kda_heap_memory_util_agg_threshold_us_east_1
  kda_cpu_util_agg_threshold_us_east_1                = var.kda_cpu_util_agg_threshold_us_east_1
  kda_threads_count_agg_threshold_us_east_1           = var.kda_threads_count_agg_threshold_us_east_1
  kda_max_exp_gc_time_agg_threshold_us_east_1         = var.kda_max_exp_gc_time_agg_threshold_us_east_1
  kda_max_exp_gc_cnt_agg_threshold_us_east_1          = var.kda_max_exp_gc_cnt_agg_threshold_us_east_1
  kda_min_exp_water_agg_threshold_us_east_1           = var.kda_min_exp_water_agg_threshold_us_east_1
  kda_bucket_kms_arn_us_east_1                        = var.kda_bucket_kms_arn_us_east_1
  lambda_bucket_kms_arn_us_east_1                     = var.lambda_bucket_kms_arn_us_east_1
}

terraform {
  backend "s3" {
    region  = "us-east-1"
    profile = ""
    bucket  = "tf-state-doppler-video"
    key     = "dmt.terraform.tfstate"
  }
}
