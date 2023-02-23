resource "aws_s3_object" "kda_agg" {
  bucket = var.kda_bucket_name
  key    = "${local.ns}-kda-agg"
  source = var.kda_agg_jar_name
}

module "kds-agg-consumer-buf-sess" {
  source     = "../kds-consumer"
  name       = "${local.ns}-kds-agg-buf-sess"
  stream_arn = module.kds-sess.kinesis_data_stream_arn
}


module "lambda-kds-buf-sess" {
  source                             = "../lambda-kds-notifier"
  lambda_function_arn                = aws_lambda_function.lambda_buf_sess.arn
  kinesis_stream_arn                 = module.kds-agg-consumer-buf-sess.kds_consumer_arn
  failed_sqs_arn                     = aws_sqs_queue.buf-sess-dlq.arn
  batch_size                         = var.batch_size
  maximum_batching_window_in_seconds = var.maximum_batching_window_in_seconds
  starting_position                  = var.starting_position
  maximum_retry_attempts             = var.maximum_retry_attempts
  maximum_record_age_in_seconds      = var.maximum_record_age_in_seconds
  bisect_batch_on_function_error     = var.bisect_batch_on_function_error
  parallelization_factor             = var.parallelization_factor
}


module "kds-raw" {
  source                       = "../provisioned-kds"
  name                         = "${local.ns}-kds-raw"
  tags                         = var.tags
  detailed_shard_level_metrics = var.detailed_shard_level_metrics
  kds_shard_count              = var.kds_raw_shard_count
}

module "kds-late" {
  source                       = "../provisioned-kds"
  name                         = "${local.ns}-kds-late"
  tags                         = var.tags
  kds_shard_count              = var.kds_late_shard_count
  detailed_shard_level_metrics = var.detailed_shard_level_metrics
}

module "kds-sess" {
  source                       = "../ondemand-kds"
  name                         = "${local.ns}-kds-sess"
  tags                         = var.tags
  detailed_shard_level_metrics = var.detailed_shard_level_metrics
}

module "firehose-raw" {
  source                   = "../firehose"
  name                     = "${local.ns}-firehose-raw"
  tags                     = var.tags
  firehose_buffer_size     = var.firehose_raw_buffer_size
  firehose_buffer_interval = var.firehose_raw_buffer_interval
  kds_arn                  = module.kds-raw.kinesis_data_stream_arn
  kms_kds_arn              = module.kds-raw.kinesis_data_stream_kms_arn
  kms_s3_arn               = var.raw_target_kms_arn
  s3_target_arn            = var.raw_target_bucket_arn
  prefix                   = "main/year=!{timestamp:YYYY}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
}

module "firehose-late" {
  source                   = "../firehose"
  name                     = "${local.ns}-firehose-late"
  tags                     = var.tags
  firehose_buffer_size     = var.firehose_late_buffer_size
  firehose_buffer_interval = var.firehose_late_buffer_interval
  kds_arn                  = module.kds-late.kinesis_data_stream_arn
  kms_kds_arn              = module.kds-late.kinesis_data_stream_kms_arn
  kms_s3_arn               = var.late_target_kms_arn
  s3_target_arn            = var.late_target_bucket_arn
  prefix                   = "main/year=!{timestamp:YYYY}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
}

module "firehose-sess" {
  source                   = "../firehose"
  name                     = "${local.ns}-firehose-sess"
  tags                     = var.tags
  firehose_buffer_size     = var.firehose_sess_buffer_size
  firehose_buffer_interval = var.firehose_sess_buffer_interval
  kds_arn                  = module.kds-sess.kinesis_data_stream_arn
  kms_kds_arn              = module.kds-sess.kinesis_data_stream_kms_arn
  kms_s3_arn               = var.sess_target_kms_arn
  s3_target_arn            = var.sess_target_bucket_arn
  prefix                   = "main/year=!{timestamp:YYYY}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
}
module "kda-agg" {
  source                  = "../kda"
  name                    = "${local.ns}-kda-agg"
  tags                    = var.tags
  saml_role               = var.saml_role
  account_id              = data.aws_caller_identity.current.account_id
  s3_kda_arn              = var.kda_bucket_arn
  kds_resource_arns       = [module.kds-raw.kinesis_data_stream_arn, module.kds-late.kinesis_data_stream_arn, module.kds-sess.kinesis_data_stream_arn, "${module.kds-raw.kinesis_data_stream_arn}/*", "${module.kds-late.kinesis_data_stream_arn}/*", "${module.kds-sess.kinesis_data_stream_arn}/*"]
  kms_resource_arns       = [module.kds-raw.kinesis_data_stream_kms_arn, module.kds-late.kinesis_data_stream_kms_arn, module.kds-sess.kinesis_data_stream_kms_arn, var.kda_bucket_kms_arn]
  vpc                     = var.vpc
  s3_object_key           = aws_s3_object.kda_agg.key
  kda_parallelism         = var.kda_agg_parallelism
  kda_parallelism_per_kpu = var.kda_agg_parallelism_per_kpu
  private_subnets         = var.private_subnets
  log_level               = var.log_level
  environment_properties  = var.environment_properties_agg
  kda_bucket_arn          = var.kda_bucket_arn
}


# output

# Command to view the status of the Fargate service
output "status" {
  value = "fargate service info"
}

# Command to deploy a new task definition to the service using Docker Compose
output "deploy" {
  value = "fargate service deploy -f docker-compose.yml"
}

# Command to scale up cpu and memory
output "scale_up" {
  value = "fargate service update -h"
}

# Command to scale out the number of tasks (container replicas)
output "scale_out" {
  value = "fargate service scale -h"
}

output "lb_dns" {
  value = aws_alb.app.dns_name
}

output "lb_zone_id" {
  value = aws_alb.app.zone_id
}

output "lb_arn" {
  value      = aws_alb.app.arn
  depends_on = [aws_alb.app]
}

output "lb_arn_suffix" {
  value      = aws_alb.app.arn_suffix
  depends_on = [aws_alb.app]
}

output "lb_tg_arn_suffix" {
  value = aws_alb_target_group.app.arn_suffix
}

output "ecs_cluster_name" {
  value      = aws_ecs_cluster.app.name
  depends_on = [aws_ecs_cluster.app]
}

output "ecs_service_name" {
  value      = aws_ecs_service.app.name
  depends_on = [aws_ecs_service.app]
}

output "kinesis_stream_name_raw" {
  value = module.kds-raw.kinesis_data_stream_name
}

output "kinesis_stream_name_late" {
  value = module.kds-late.kinesis_data_stream_name
}

output "kinesis_stream_name_sess" {
  value = module.kds-sess.kinesis_data_stream_name
}

output "kinesis_firehose_name_raw" {
  value = module.firehose-raw.firehose_delivery_stream_name
}

output "kinesis_firehose_name_sess" {
  value = module.firehose-sess.firehose_delivery_stream_name
}

output "kinesis_kda_name_agg" {
  value = module.kda-agg.kda_app_name
}

output "timestream_db_name" {
  value = aws_timestreamwrite_database.timestream_db.id
}

output "sessions_table_name" {
  value = aws_timestreamwrite_table.sessions_table.table_name
}

output "timestream_kms_arn" {
  value = aws_kms_key.timestream.arn
}

output "sqs_raw_dlq_id" {
  value = aws_sqs_queue.dlq.id
}

output "endpoint" {
  value = "https://${local.subdomain}"
}

output "sqs_lambda_dlq_buf_sess_id" {
  value = aws_sqs_queue.buf-sess-dlq.id
}

output "ecsTaskExecutionRoleARN" {
  value = aws_iam_role.ecsTaskExecutionRole.arn
}

output "ecsTaskExecutionRoleName" {
  value = aws_iam_role.ecsTaskExecutionRole.name
}
