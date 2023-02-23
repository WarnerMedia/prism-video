resource "aws_s3_bucket" "lblogs_athena" {
  bucket        = "${var.app}-athena-${var.environment}"
  force_destroy = true
  tags          = var.tags

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lblogs_athena" {
  bucket = aws_s3_bucket.lblogs_athena.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.lblogs_athena.arn
    }
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "lblogs_athena" {
  bucket = aws_s3_bucket.lblogs_athena.id

  rule {
    id     = "multipart"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }
  }

  rule {
    id     = "intelligent-tiering"
    status = "Enabled"
    transition {
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}



resource "aws_kms_key" "lblogs_athena" {
  enable_key_rotation = true
  tags                = var.tags
}

resource "aws_kms_alias" "lblogs_athena" {
  name          = "alias/${aws_s3_bucket.lblogs_athena.bucket}-key"
  target_key_id = aws_kms_key.lblogs_athena.key_id
}

resource "aws_athena_database" "lblogs_athena" {
  name   = "doppler_video_p1_lblogs_${var.environment}"
  bucket = aws_s3_bucket.lblogs_athena.id
}

resource "aws_athena_named_query" "lblogs_athena" {
  name     = "${local.ns}-create-table"
  database = aws_athena_database.lblogs_athena.name
  query    = templatefile("${path.module}/lblogs_athena.tftpl", { bucket = aws_s3_bucket.lb_access_logs_app.id, account_id = data.aws_caller_identity.current.account_id, region = var.region })
}
