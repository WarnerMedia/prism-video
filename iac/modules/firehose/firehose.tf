resource "aws_cloudwatch_log_group" "firehose" {
  name = var.name
}

resource "aws_cloudwatch_log_stream" "firehose" {
  name           = var.name
  log_group_name = aws_cloudwatch_log_group.firehose.name
}

resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  name        = var.name
  tags        = var.tags
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = var.kds_arn
    role_arn           = aws_iam_role.firehose.arn
  }

  extended_s3_configuration {
    role_arn        = aws_iam_role.firehose.arn
    buffer_size     = var.firehose_buffer_size
    buffer_interval = var.firehose_buffer_interval

    # s3
    bucket_arn = var.s3_target_arn
    prefix     = var.prefix

    # logging
    error_output_prefix = "errors"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = aws_cloudwatch_log_stream.firehose.name
    }

    # # ... other configuration ...
    # data_format_conversion_configuration {
    #   input_format_configuration {
    #     deserializer {
    #       open_x_json_ser_de {}
    #     }
    #   }

    #   output_format_configuration {
    #     serializer {
    #       parquet_ser_de {
    #         compression = "GZIP"
    #       }
    #     }
    #   }
    #   schema_configuration {
    #     database_name = aws_glue_catalog_database.glue_catalog_database.name
    #     role_arn      = aws_iam_role.firehose_iam_role.arn
    #     table_name    = aws_glue_catalog_table.glue_catalog_table_main.name
    #     version_id    = "LATEST"
    #     region        = var.region
    #   }
    # }
  }
}

resource "aws_iam_role" "firehose" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.firehose_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "firehose_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "firehose" {
  name   = var.name
  role   = aws_iam_role.firehose.name
  policy = data.aws_iam_policy_document.firehose.json
}

data "aws_iam_policy_document" "firehose" {

  # access to the data stream
  statement {
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards"
    ]
    resources = [var.kds_arn]
  }

  # use of encryption keys
  statement {
    actions = [
      "kms:*",
    ]
    resources = [
      var.kms_kds_arn,
      var.kms_s3_arn
    ]
  }

  # s3 access
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      var.s3_target_arn,
      "${var.s3_target_arn}/*"
    ]
  }

  # logging access
  statement {
    actions   = ["logs:PutLogEvents"]
    resources = [aws_cloudwatch_log_stream.firehose.arn]
  }
}

output "firehose_delivery_stream_name" {
  value = aws_kinesis_firehose_delivery_stream.firehose.name
}
