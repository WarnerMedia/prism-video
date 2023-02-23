module "video_source_detail" {
  source                                       = "../video_detail"
  app                                          = var.app
  internal                                     = var.internal
  kpl_port                                     = var.kpl_port
  log_level                                    = var.log_level
  container_port_app                           = var.container_port_app
  health_check_app                             = var.health_check_app
  saml_role                                    = var.saml_role
  deregistration_delay                         = var.deregistration_delay
  tags                                         = var.tags
  route53_zone_id                              = var.route53_zone_id
  hosted_zone                                  = var.hosted_zone
  common_subdomain                             = var.common_subdomain
  kds_raw_shard_count                          = var.kds_raw_shard_count
  kds_agg_shard_count                          = var.kds_agg_shard_count
  kds_late_shard_count                         = var.kds_late_shard_count
  kds_sess_shard_count                         = var.kds_sess_shard_count
  firehose_agg_buffer_interval                 = var.firehose_agg_buffer_interval
  firehose_agg_buffer_size                     = var.firehose_agg_buffer_size
  firehose_raw_buffer_interval                 = var.firehose_raw_buffer_interval
  firehose_raw_buffer_size                     = var.firehose_raw_buffer_size
  firehose_late_buffer_interval                = var.firehose_late_buffer_interval
  firehose_late_buffer_size                    = var.firehose_late_buffer_size
  firehose_sess_buffer_interval                = var.firehose_sess_buffer_interval
  firehose_sess_buffer_size                    = var.firehose_sess_buffer_size
  environment                                  = var.environment
  region                                       = var.region
  vpc                                          = var.vpc
  raw_target_bucket_id                         = aws_s3_bucket.raw_target.id
  raw_target_bucket_arn                        = aws_s3_bucket.raw_target.arn
  late_target_bucket_arn                       = aws_s3_bucket.late_target.arn
  sess_target_bucket_arn                       = aws_s3_bucket.sess_target.arn
  raw_target_kms_arn                           = aws_kms_key.raw_s3.arn
  late_target_kms_arn                          = aws_kms_key.late_s3.arn
  sess_target_kms_arn                          = aws_kms_key.sess_s3.arn
  private_subnets                              = var.private_subnets
  public_subnets                               = var.public_subnets
  ecs_autoscale_min_instances_app              = var.ecs_autoscale_min_instances_app
  ecs_autoscale_max_instances_app              = var.ecs_autoscale_max_instances_app
  kda_agg_parallelism                          = var.kda_agg_parallelism
  kda_agg_parallelism_per_kpu                  = var.kda_agg_parallelism_per_kpu
  ecs_task_kpl_env                             = var.ecs_task_kpl_env
  environment_properties_agg                   = var.environment_properties_agg
  kda_bucket_name                              = var.kda_bucket_name
  kda_bucket_arn                               = var.kda_bucket_arn
  kda_bucket_kms_arn                           = var.kda_bucket_kms_arn
  kda_agg_jar_name                             = var.kda_agg_jar_name
  ecs_as_cpu_high_threshold_per                = var.ecs_as_cpu_high_threshold_per
  num_of_containers_to_add_during_scaling      = var.num_of_containers_to_add_during_scaling
  num_of_containers_to_remove_during_scaledown = var.num_of_containers_to_remove_during_scaledown
  detailed_shard_level_metrics                 = var.detailed_shard_level_metrics
  timestream_magnetic_ret_pd_in_days           = var.timestream_magnetic_ret_pd_in_days
  timestream_memory_ret_pd_in_hours            = var.timestream_memory_ret_pd_in_hours
  kds_timestream_buf_sess_lambda_env           = var.kds_timestream_buf_sess_lambda_env
  lambda_bucket_name                           = var.lambda_bucket_name
  lambda_bucket_arn                            = var.lambda_bucket_arn
  lambda_bucket_kms_arn                        = var.lambda_bucket_kms_arn
  loader_role_arn                              = var.west_loader_role_arn
  ecr_loader_arn                               = var.west_ecr_loader_arn
  ecr_loader_ltpd_arn                          = var.west_ecr_loader_ltpd_arn
  ecr_reader_ltpd_arn                          = var.west_ecr_reader_ltpd_arn
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
}

output "lb_dns" {
  value = module.video_source_detail.lb_dns
}

output "lb_zone_id" {
  value = module.video_source_detail.lb_zone_id
}

output "lb_arn" {
  value      = module.video_source_detail.lb_arn
  depends_on = [module.video_source_detail.lb_arn]
}

output "lb_arn_suffix" {
  value = module.video_source_detail.lb_arn_suffix
}

output "lb_tg_arn_suffix" {
  value = module.video_source_detail.lb_tg_arn_suffix
}

output "ecs_cluster_name" {
  value = module.video_source_detail.ecs_cluster_name
}

output "ecs_service_name" {
  value = module.video_source_detail.ecs_service_name
}

output "kinesis_stream_name_raw" {
  value = module.video_source_detail.kinesis_stream_name_raw
}

output "kinesis_stream_name_late" {
  value = module.video_source_detail.kinesis_stream_name_late
}

output "kinesis_stream_name_sess" {
  value = module.video_source_detail.kinesis_stream_name_sess
}

output "kinesis_firehose_name_raw" {
  value = module.video_source_detail.kinesis_firehose_name_raw
}

output "kinesis_firehose_name_sess" {
  value = module.video_source_detail.kinesis_firehose_name_sess
}

output "kda_app_name_agg" {
  value = module.video_source_detail.kinesis_kda_name_agg
}

output "source_raw_target_bucket_arn" {
  value = aws_s3_bucket.raw_target.arn
}

output "source_raw_target_bucket_kms_arn" {
  value = aws_kms_key.raw_s3.arn
}

output "source_late_target_bucket_arn" {
  value = aws_s3_bucket.late_target.arn
}

output "source_sess_target_bucket_kms_arn" {
  value = aws_kms_key.sess_s3.arn
}

output "source_sess_target_bucket_arn" {
  value = aws_s3_bucket.sess_target.arn
}

output "source_late_target_bucket_kms_arn" {
  value = aws_kms_key.late_s3.arn
}


output "kinesis_stream_id_raw" {
  value = "doppler_video_${var.environment}_kds_raw"
}

output "kinesis_stream_id_sess" {
  value = "doppler_video_${var.environment}_kds_sess"
}

output "timestream_db_name" {
  value = module.video_source_detail.timestream_db_name
}

output "sessions_table_name" {
  value = module.video_source_detail.sessions_table_name
}

output "timestream_kms_arn" {
  value = module.video_source_detail.timestream_kms_arn
}

output "cluster_name" {
  value = module.video_source_detail.cluster_name
}
