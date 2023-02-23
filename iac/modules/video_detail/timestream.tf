resource "aws_kms_key" "timestream" {
  description             = "KMS Key for ${local.ns}-timestream"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
  policy                  = data.aws_iam_policy_document.sched_query_kms_role_policy.json
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

// SNS topic for scheduled queries
resource "aws_sns_topic" "sched_query_topic" {
  name = "${local.ns}-sched-query"
}


// S3 bucket for scheduled query errors
resource "aws_s3_bucket" "sched_query" {
  bucket        = "${local.ns}-sched-query"
  force_destroy = true
  tags          = var.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.timestream.arn
      }
    }
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "sched_query" {
  bucket = aws_s3_bucket.sched_query.id

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


// Create a role for the scheduled query
resource "aws_iam_role" "sched_query_role" {
  name               = "${local.ns}-sched-query"
  assume_role_policy = data.aws_iam_policy_document.sched_query_role_assume_role_policy.json
  tags               = var.tags
}

# assigns the app policy
resource "aws_iam_role_policy" "sched_query_policy" {
  name   = "${local.ns}-sched-query"
  role   = aws_iam_role.sched_query_role.id
  policy = data.aws_iam_policy_document.sched_query_policy.json
}

data "aws_iam_policy_document" "sched_query_policy" {

  statement {
    actions = [
      "sns:*",
    ]
    resources = [aws_sns_topic.sched_query_topic.arn]
  }

  statement {
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.sched_query.arn,
      "${aws_s3_bucket.sched_query.arn}/*"
    ]
  }

  statement {
    actions = [
      "kms:*",
    ]
    resources = [
      aws_kms_key.timestream.arn
    ]
  }

  statement {
    actions = [
      "timestream:*"
    ]
    resources = ["*"]
  }
}

# allow role to be assumed by ecs and local saml users (for development)
data "aws_iam_policy_document" "sched_query_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["timestream.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "sched_query_kms_role_policy" {
  statement {
    actions = [
      "kms:*"
    ]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [aws_iam_role.sched_query_role.arn,
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

  }
}
