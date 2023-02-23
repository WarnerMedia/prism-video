resource "aws_s3_bucket" "sess_target" {
  bucket        = var.sess_target_bucket_name
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sess_target" {
  bucket = aws_s3_bucket.sess_target.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.sess_s3.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "sess_target" {
  bucket = aws_s3_bucket.sess_target.id

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

resource "aws_s3_bucket_versioning" "sess_target" {
  bucket = aws_s3_bucket.sess_target.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "sess_s3" {
  description             = "KMS Key for ${var.sess_target_bucket_name} s3 bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "sess_s3" {
  name          = "alias/${aws_s3_bucket.sess_target.bucket}-key"
  target_key_id = aws_kms_key.sess_s3.key_id
}
