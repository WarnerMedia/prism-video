resource "aws_s3_bucket" "late_target" {
  bucket        = var.late_target_bucket_name
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "late_target" {
  bucket = aws_s3_bucket.late_target.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.late_s3.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "late_target" {
  bucket = aws_s3_bucket.late_target.id

  rule {
    id     = "auto-delete-incomplete-after-x-days"
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

resource "aws_s3_bucket_versioning" "late_target" {
  bucket = aws_s3_bucket.late_target.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "late_s3" {
  description             = "KMS Key for ${var.late_target_bucket_name} s3 bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "late_s3" {
  name          = "alias/${aws_s3_bucket.late_target.bucket}-key"
  target_key_id = aws_kms_key.late_s3.key_id
}
