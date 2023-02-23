module "lambda_s3_notifier_late" {
  source              = "../lambda-s3-notifier"
  lambda_function_arn = aws_lambda_function.lambda_s3.arn
  s3_bucket_arn       = aws_s3_bucket.late_target.arn
  s3_bucket_id        = aws_s3_bucket.late_target.id
}

resource "aws_s3_object" "kda_agg" {
  bucket = var.kda_bucket_name
  key    = "${local.ns}-kda-agg"
  source = var.kda_agg_jar_name
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

module "firehose-late" {
  source                   = "../firehose"
  name                     = "${local.ns}-firehose-late"
  tags                     = var.tags
  firehose_buffer_size     = var.firehose_late_buffer_size
  firehose_buffer_interval = var.firehose_late_buffer_interval
  kds_arn                  = module.kds-late.kinesis_data_stream_arn
  kms_kds_arn              = module.kds-late.kinesis_data_stream_kms_arn
  kms_s3_arn               = aws_kms_key.late_s3.arn
  s3_target_arn            = aws_s3_bucket.late_target.arn
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
  kms_s3_arn               = aws_kms_key.sess_s3.arn
  s3_target_arn            = aws_s3_bucket.sess_target.arn
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

output "kinesis_stream_name_raw" {
  value = module.kds-raw.kinesis_data_stream_name
}

output "kinesis_stream_name_sess" {
  value = module.kds-sess.kinesis_data_stream_name
}

output "kinesis_stream_name_late" {
  value = module.kds-late.kinesis_data_stream_name
}

output "kinesis_firehose_name_sess" {
  value = module.firehose-sess.firehose_delivery_stream_name
}

output "kinesis_kda_name_agg" {
  value = module.kda-agg.kda_app_name
}

output "kinesis_stream_id_raw" {
  value = "${local.ns}_kds_raw"
}

output "kinesis_stream_id_sess" {
  value = "${local.ns}_kds_sess"
}

