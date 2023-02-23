resource "aws_kms_key" "timestream" {
  description             = "KMS Key for ${local.ns}-timestream"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_timestreamwrite_database" "timestream_db" {
  database_name = local.ns
  kms_key_id    = aws_kms_key.timestream.arn

  tags = var.tags
}

resource "aws_timestreamwrite_table" "sessions_table" {
  database_name = aws_timestreamwrite_database.timestream_db.database_name
  table_name    = "sessions"

  retention_properties {
    magnetic_store_retention_period_in_days = var.timestream_magnetic_ret_pd_in_days
    memory_store_retention_period_in_hours  = var.timestream_memory_ret_pd_in_hours
  }

  tags = var.tags
}
