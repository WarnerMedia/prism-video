resource "aws_s3_bucket" "kda" {
  bucket        = "${var.app}-kda"
  force_destroy = true
  tags          = var.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.s3_kda.arn
      }
    }
  }

  # stuff for cross region replication
  versioning {
    enabled = true
  }
}

resource "aws_kms_key" "s3_kda" {
  description             = "KMS Key for ${var.app}-kda s3 bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "s3_kda" {
  name          = "alias/${aws_s3_bucket.kda.bucket}-kda-key"
  target_key_id = aws_kms_key.s3_kda.key_id
}

resource "aws_s3_bucket_object" "kda_agg" {
  bucket = aws_s3_bucket.kda.bucket
  key    = "${var.app}-kda-agg"
  source = "wm-kda-agg-src-consumer-1.1.jar"
}

# explicitly block public access
resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket                  = aws_s3_bucket.kda.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "kda_s3_bucket" {
  value = aws_s3_bucket.kda.bucket
}

output "kda_s3_kms_arn" {
  value = aws_kms_key.s3_kda.arn
}
