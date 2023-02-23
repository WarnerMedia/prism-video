# app/env to scaffold
# common variables in all environments
app                                = "doppler-video"
aws_profile                        = ""
internal                           = false
kpl_port                           = 3000
log_level                          = "WARN"
saml_role                          = ""
firehose_agg_buffer_size           = 64
firehose_agg_buffer_interval       = 300
firehose_sess_buffer_size          = 64
firehose_sess_buffer_interval      = 300
stream_position_raw                = "LATEST"
kda_agg_jar_name                   = "flink_app.jar"
timestream_ingest_batch_size       = "99"
shard_use_adaptive_reads           = "false"
shard_getrecords_interval_millis   = "500"
shard_getrecords_max               = "10000"
kda_use_efo                        = "true"
late_arriving_secs                 = 120
video_session_ttl_secs             = 1800
state_ttl_secs                     = 3600
batch_size                         = "500"
maximum_batching_window_in_seconds = "10"
starting_position                  = "LATEST"
maximum_retry_attempts             = "25"
maximum_record_age_in_seconds      = "-1"
bisect_batch_on_function_error     = "true"
parallelization_factor             = "10"


detailed_shard_level_metrics = [
  "IncomingBytes",
  "OutgoingBytes",
  "WriteProvisionedThroughputExceeded",
  "ReadProvisionedThroughputExceeded",
  "IncomingRecords",
  "OutgoingRecords"
]
timestream_magnetic_ret_pd_in_days = 7
timestream_memory_ret_pd_in_hours  = 2

tags = {
  application   = "doppler-video"
  customer      = "video-qos"
  contact-email = ""
  environment   = "slpd"
  team          = "video-qos"
}

hosted_zone        = "<your subdomain>"
common_subdomain   = "<your subdomain>"
common_environment = "slpd"
destination_region = "us-east-1"

# variables that differ in each environment
# us-east-1
environment_us_east_1                 = "slpduseast1"
region_us_east_1                      = "us-east-1"
vpc_us_east_1                         = "<vpc id in useast1>"
private_subnets_us_east_1             = "<private subnets within vpc in useast1>"
public_subnets_us_east_1              = "<public subnets within vpc in useast1>"
agg_target_bucket_name_us_east_1      = "doppler-video-slpd-agg-useast1"
sess_target_bucket_name_us_east_1     = "doppler-video-slpd-sess-useast1"
kds_raw_shard_count_us_east_1         = 1
kds_agg_shard_count_us_east_1         = 1
kds_sess_shard_count_us_east_1        = 1
kda_agg_parallelism_us_east_1         = 1
kda_agg_parallelism_per_kpu_us_east_1 = 1
firehose_late_buffer_size             = 8
firehose_late_buffer_interval         = 60
late_target_bucket_name_us_east_1     = "doppler-video-slpd-late-useast1"
kds_late_shard_count_us_east_1        = 1

# thresholds for alarms
high_agg_kds_putrecs_failedrecs_threshold_us_east_1 = "100"
high_raw_kpl_retries_threshold_us_east_1            = "100000"
high_agg_kpl_retries_threshold_us_east_1            = "4000"
kda_records_out_per_sec_agg_threshold_us_east_1     = "0"
kda_millis_behind_latest_agg_threshold_us_east_1    = "380000"
kda_last_checkpoint_dur_agg_threshold_us_east_1     = "7000"
kda_last_checkpoint_size_agg_threshold_us_east_1    = "250000000"
kda_heap_memory_util_agg_threshold_us_east_1        = "90"
kda_cpu_util_agg_threshold_us_east_1                = "90"
kda_threads_count_agg_threshold_us_east_1           = "2000"
kda_max_exp_gc_time_agg_threshold_us_east_1         = "90"
kda_max_exp_gc_cnt_agg_threshold_us_east_1          = "90"
kda_min_exp_water_agg_threshold_us_east_1           = "90"
timestream_system_err_threshold_us_east_1           = "50"
timestream_user_err_threshold_us_east_1             = "50"
timestream_tbl_suc_req_latency_threshold_us_east_1  = "200"
timestream_buf_error_threshold_us_east_1            = "5"

# get these values from the output of the base non-prod or prod account level info
kda_bucket_kms_arn_us_east_1    = "<kda deployment kms arn in useast1>"
lambda_bucket_kms_arn_us_east_1 = "<lambda deployment kms arn in useast1>"
