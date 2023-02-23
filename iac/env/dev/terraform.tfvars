# app/env to scaffold
# common variables in all environments
app                                          = "doppler-video"
aws_profile                                  = ""
internal                                     = false
kpl_port                                     = 3000
log_level                                    = "WARN"
saml_role                                    = ""
container_port_app                           = "8081"
health_check_app                             = "/health"
firehose_raw_buffer_size                     = 64
firehose_raw_buffer_interval                 = 300
firehose_agg_buffer_size                     = 64
firehose_agg_buffer_interval                 = 300
firehose_late_buffer_size                    = 8
firehose_late_buffer_interval                = 60
firehose_sess_buffer_size                    = 64
firehose_sess_buffer_interval                = 300
deregistration_delay                         = 10
stream_position_raw                          = "LATEST"
kda_agg_jar_name                             = "flink_app.jar"
timestream_ingest_batch_size                 = "99"
shard_use_adaptive_reads                     = "false"
shard_getrecords_interval_millis             = "500"
shard_getrecords_max                         = "10000"
kda_use_efo                                  = "true"
ecs_as_cpu_high_threshold_per                = 50
num_of_containers_to_add_during_scaling      = 25
num_of_containers_to_remove_during_scaledown = -5
payload_display_on_error                     = "true"
payload_limit                                = "400000"
enable_encryption                            = "false"
ecs_autoscale_min_instances_loader           = 1
test_without_kpl                             = "false"
late_arriving_secs                           = 30
video_session_ttl_secs                       = 1800
state_ttl_secs                               = 3600
batch_size                                   = "500"
maximum_batching_window_in_seconds           = "10"
starting_position                            = "LATEST"
maximum_retry_attempts                       = "25"
maximum_record_age_in_seconds                = "-1"
bisect_batch_on_function_error               = "true"
parallelization_factor                       = "10"

detailed_shard_level_metrics = [
  "IncomingBytes",
  "OutgoingBytes",
  "WriteProvisionedThroughputExceeded",
  "ReadProvisionedThroughputExceeded",
  "IncomingRecords",
  "OutgoingRecords"
]
timestream_magnetic_ret_pd_in_days = 7
timestream_memory_ret_pd_in_hours  = 3
tags = {
  application   = "doppler-video"
  customer      = "video-qos"
  contact-email = ""
  environment   = "dev"
  team          = "video-qos"
}
hosted_zone        = "<your subdomain>"
common_subdomain   = "<your subdomain>"
common_environment = "prod"
destination_region = "us-east-1"
source_region      = "us-west-2"
snowflake_iam_user = "<snowflake arn>"

# variables that differ in each environment
# us-east-1
environment_us_east_1                     = "devuseast1"
region_us_east_1                          = "us-east-1"
vpc_us_east_1                             = "<vpc id in useast1>"
private_subnets_us_east_1                 = "<private subnets within vpc in useast1>"
public_subnets_us_east_1                  = "<public subnets within vpc in useast1>"
raw_target_bucket_name_us_east_1          = "doppler-video-dev-raw-useast1"
agg_target_bucket_name_us_east_1          = "doppler-video-dev-agg-useast1"
late_target_bucket_name_us_east_1         = "doppler-video-dev-late-useast1"
sess_target_bucket_name_us_east_1         = "doppler-video-dev-sess-useast1"
ecs_autoscale_min_instances_app_us_east_1 = 1
ecs_autoscale_max_instances_app_us_east_1 = 4
kds_raw_shard_count_us_east_1             = 1
kds_agg_shard_count_us_east_1             = 1
kds_late_shard_count_us_east_1            = 1
kds_sess_shard_count_us_east_1            = 1
kda_agg_parallelism_us_east_1             = 1
kda_agg_parallelism_per_kpu_us_east_1     = 1
ecs_task_kpl_east_env = [
  {
    "name" : "KINESIS_STREAM",
    "value" : "doppler-video-devuseast1-kds-raw"
    }, {
    "name" : "PORT",
    "value" : "3000"
    }, {
    "name" : "ERROR_SOCKET_PORT",
    "value" : "3001"
    }, {
    "name" : "AWS_DEFAULT_REGION",
    "value" : "us-east-1"
}]

ecs_task_kpl_dmt_east_env = [
  {
    "name" : "KINESIS_STREAM",
    "value" : "doppler-video-dmtuseast1-kds-raw"
    }, {
    "name" : "PORT",
    "value" : "3000"
    }, {
    "name" : "ERROR_SOCKET_PORT",
    "value" : "3001"
    }, {
    "name" : "AWS_DEFAULT_REGION",
    "value" : "us-east-1"
}]

ecs_task_kpl_slpd_east_env = [
  {
    "name" : "KINESIS_STREAM",
    "value" : "doppler-video-slpduseast1-kds-raw"
    }, {
    "name" : "PORT",
    "value" : "3010"
    }, {
    "name" : "ERROR_SOCKET_PORT",
    "value" : "3011"
    }, {
    "name" : "AWS_DEFAULT_REGION",
    "value" : "us-east-1"
}]

kda-records-out-per-sec-agg-enabled  = "true"
kda-millis-behind-latest-agg-enabled = "true"
kda-last-checkpoint-dur-agg-enabled  = "false"
kda-last-checkpoint-size-agg-enabled = "false"

# thresholds for alarms
too_many_requests_threshold_us_east_1               = "10000"
too_many_5xx_response_threshold_us_east_1           = "500"
high_response_time_threshold_us_east_1              = "1"
high_running_task_count_threshold_us_east_1         = "350"
high_cpu_utilization_threshold_us_east_1            = "90"
high_memory_utilization_threshold_us_east_1         = "90"
high_raw_kds_putrecs_failedrecs_threshold_us_east_1 = "500"
high_agg_kds_putrecs_failedrecs_threshold_us_east_1 = "100"
high_raw_kpl_retries_threshold_us_east_1            = "750"
high_agg_kpl_retries_threshold_us_east_1            = "500"
kda_records_out_per_sec_agg_threshold_us_east_1     = "0"
kda_millis_behind_latest_agg_threshold_us_east_1    = "380000"
kda_last_checkpoint_dur_agg_threshold_us_east_1     = "6000"
kda_last_checkpoint_size_agg_threshold_us_east_1    = "100000000"
kda_heap_memory_util_agg_threshold_us_east_1        = "90"
kda_cpu_util_agg_threshold_us_east_1                = "90"
kda_threads_count_agg_threshold_us_east_1           = "2000"
kda_max_exp_gc_time_agg_threshold_us_east_1         = "90"
kda_max_exp_gc_cnt_agg_threshold_us_east_1          = "90"
kda_min_exp_water_agg_threshold_us_east_1           = "90"
timestream_system_err_threshold_us_east_1           = "2"
timestream_user_err_threshold_us_east_1             = "2"
timestream_tbl_suc_req_latency_threshold_us_east_1  = "200"
timestream_buf_error_threshold_us_east_1            = "5"

# us-west-2
environment_us_west_2                     = "devuswest2"
region_us_west_2                          = "us-west-2"
vpc_us_west_2                             = "<vpc id in uswest2>"
private_subnets_us_west_2                 = "<private subnets within vpc in uswest2>"
public_subnets_us_west_2                  = "<public subnets within vpc in useast1>"
raw_target_bucket_name_us_west_2          = "doppler-video-dev-raw-uswest2"
agg_target_bucket_name_us_west_2          = "doppler-video-dev-agg-uswest2"
late_target_bucket_name_us_west_2         = "doppler-video-dev-late-uswest2"
sess_target_bucket_name_us_west_2         = "doppler-video-dev-sess-uswest2"
ecs_autoscale_min_instances_app_us_west_2 = 1
ecs_autoscale_max_instances_app_us_west_2 = 4
kds_raw_shard_count_us_west_2             = 1
kds_agg_shard_count_us_west_2             = 1
kds_late_shard_count_us_west_2            = 1
kds_sess_shard_count_us_west_2            = 1
kda_agg_parallelism_us_west_2             = 1
kda_agg_parallelism_per_kpu_us_west_2     = 1
ecs_task_kpl_west_env = [
  {
    "name" : "KINESIS_STREAM",
    "value" : "doppler-video-devuswest2-kds-raw"
    }, {
    "name" : "PORT",
    "value" : "3000"
    }, {
    "name" : "ERROR_SOCKET_PORT",
    "value" : "3001"
    }, {
    "name" : "AWS_DEFAULT_REGION",
    "value" : "us-west-2"
}]

# thresholds for alarms
too_many_requests_threshold_us_west_2               = "660000"
too_many_5xx_response_threshold_us_west_2           = "500"
high_response_time_threshold_us_west_2              = "1"
high_running_task_count_threshold_us_west_2         = "350"
high_cpu_utilization_threshold_us_west_2            = "90"
high_memory_utilization_threshold_us_west_2         = "90"
high_raw_kds_putrecs_failedrecs_threshold_us_west_2 = "500"
high_agg_kds_putrecs_failedrecs_threshold_us_west_2 = "100"
high_raw_kpl_retries_threshold_us_west_2            = "500"
high_agg_kpl_retries_threshold_us_west_2            = "500"
kda_records_out_per_sec_agg_threshold_us_west_2     = "0"
kda_millis_behind_latest_agg_threshold_us_west_2    = "60000"
kda_last_checkpoint_dur_agg_threshold_us_west_2     = "8000"
kda_last_checkpoint_size_agg_threshold_us_west_2    = "100000000"
kda_heap_memory_util_agg_threshold_us_west_2        = "90"
kda_cpu_util_agg_threshold_us_west_2                = "90"
kda_threads_count_agg_threshold_us_west_2           = "2000"
kda_max_exp_gc_time_agg_threshold_us_west_2         = "90"
kda_max_exp_gc_cnt_agg_threshold_us_west_2          = "90"
kda_min_exp_water_agg_threshold_us_west_2           = "90"
timestream_system_err_threshold_us_west_2           = "2"
timestream_user_err_threshold_us_west_2             = "2"
timestream_tbl_suc_req_latency_threshold_us_west_2  = "200"
timestream_buf_error_threshold_us_west_2            = "5"

# get these values from the output of the base dev account level info
kda_bucket_kms_arn_us_east_1 = "<kda deployment kms arn in useast1>"
kda_bucket_kms_arn_us_west_2 = "<kda deployment kms arn in uswest2>"

lambda_bucket_kms_arn_us_east_1 = "<lambda deployment kms arn in useast1>"
lambda_bucket_kms_arn_us_west_2 = "<lambda deployment kmrearn in uswest2>"

east_ecr_loader_arn = "<ecr arn for slow prod / dmt loader in useast1>"
west_ecr_loader_arn = "<ecr arn for slow prod / dmt loader in uswset2>"

east_loader_role_arn = "<iam role arn for loader in useast1>"
west_loader_role_arn = "<iam role arn for loader in uswest2>"

east_ecr_loader_ltpd_arn = "<ecr arn for load test loader in useast1>"
west_ecr_loader_ltpd_arn = "<ecr arn for load test loader in uswest2>"

east_ecr_reader_ltpd_arn = "<ecr arn for load test reader in useast1>"
west_ecr_reader_ltpd_arn = "<ecr arn for load test reader in uswest2>"
