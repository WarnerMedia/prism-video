resource "aws_s3_bucket" "lambda" {
  bucket        = "${var.app}-lambda"
  force_destroy = true
  tags          = var.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.s3_lambda.arn
      }
    }
  }

  # stuff for cross region replication
  versioning {
    enabled = true
  }
}

resource "aws_kms_key" "s3_lambda" {
  description             = "KMS Key for ${var.app}-lambda s3 bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "s3_lambda" {
  name          = "alias/${aws_s3_bucket.lambda.bucket}-lambda-key"
  target_key_id = aws_kms_key.s3_lambda.key_id
}

# explicitly block public access
resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket                  = aws_s3_bucket.lambda.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "lambda_s3_bucket" {
  value = aws_s3_bucket.lambda.bucket
}

output "lambda_s3_kms_arn" {
  value = aws_kms_key.s3_lambda.arn
}
