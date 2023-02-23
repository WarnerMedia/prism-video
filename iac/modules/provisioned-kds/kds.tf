resource "aws_kinesis_stream" "kds" {
  name             = var.name
  shard_count      = var.kds_shard_count
  retention_period = 24
  encryption_type  = "KMS"
  kms_key_id       = aws_kms_key.kds.id
  tags             = var.tags

  shard_level_metrics = var.detailed_shard_level_metrics

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

resource "aws_kms_key" "kds" {
  description             = "KMS Key for ${var.name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

output "kinesis_data_stream_name" {
  value = aws_kinesis_stream.kds.name
}

output "kinesis_data_stream_arn" {
  value = aws_kinesis_stream.kds.arn
}

output "kinesis_data_stream_kms_arn" {
  value = aws_kms_key.kds.arn
}
