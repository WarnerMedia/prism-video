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

resource "aws_s3_bucket_replication_configuration" "sess_target" {
  bucket = aws_s3_bucket.sess_target.id
  role   = aws_iam_role.sess_replication.arn

  rule {
    id       = "${var.app}-${var.environment}sess-repl-source-to-dest"
    priority = 2
    status   = "Enabled"

    filter {
    }

    delete_marker_replication {
      status = "Enabled"
    }

    destination {
      bucket        = var.destination_sess_target_bucket_arn
      storage_class = "STANDARD"
      encryption_configuration {
        replica_kms_key_id = var.destination_sess_target_bucket_kms_arn
      }

      metrics {
        status = "Enabled"
      }
    }
    source_selection_criteria {
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
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

resource "aws_iam_role" "sess_replication" {
  name = "${var.app}-${var.environment}-sess-replication-role-source"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "sess_replication" {
  name = "${var.app}-${var.environment}-sess-replication-role-policy-source"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "s3:ListBucket",
          "s3:GetReplicationConfiguration",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.sess_target.arn}",
        "${aws_s3_bucket.sess_target.arn}/*"        
      ]
    },
    {
      "Action": [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": "${var.destination_sess_target_bucket_arn}/*"
    },
    {
      "Action": [
        "kms:Decrypt"
      ],
      "Effect": "Allow",
      "Condition": {
        "StringLike": {
          "kms:ViaService": "s3.${var.region}.amazonaws.com",
          "kms:EncryptionContext:aws:s3:arn": [
            "${aws_s3_bucket.sess_target.arn}/*"
          ]
        }
      },
      "Resource": [
        "${aws_kms_key.sess_s3.arn}"
      ]
    },
    {
      "Action": [
        "kms:Encrypt"
      ],
      "Effect": "Allow",
      "Condition": {
        "StringLike": {
          "kms:ViaService": "s3.${var.destination_region}.amazonaws.com",
          "kms:EncryptionContext:aws:s3:arn": [
            "${var.destination_sess_target_bucket_arn}/*"
          ]
        }
      },
      "Resource": [
          "${var.destination_sess_target_bucket_kms_arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "sess_replication" {
  role       = aws_iam_role.sess_replication.name
  policy_arn = aws_iam_policy.sess_replication.arn
}
