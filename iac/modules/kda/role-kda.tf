# creates an application role that the container/task runs as
resource "aws_iam_role" "kda_role" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.kda_role_assume.json
  tags               = var.tags
}

# assigns the app policy
resource "aws_iam_role_policy" "kda_role_policy" {
  name   = "${var.name}-role-policy"
  role   = aws_iam_role.kda_role.id
  policy = data.aws_iam_policy_document.kda_policy_doc.json
}

data "aws_iam_policy_document" "kda_policy_doc" {

  # access to read / write to kinesis data streams on both the raw and agg streams
  statement {
    actions = [
      "kinesis:*",
    ]
    resources = var.kds_resource_arns
  }

  # allow kda to read / write data to the kinesis data streams
  statement {
    actions = [
      "kms:*",
    ]
    resources = var.kms_resource_arns
  }

  # allow kda to access bucket to load jars(as in flink jobs)
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      var.kda_bucket_arn,
      "${var.kda_bucket_arn}/*"
    ]
  }

  # allow kda to log events
  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
  }


  statement {
    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeDhcpOptions"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = [
      "*"
    ]
  }

  # access to write to timestream tables
  # THIS IS EXCESSIVELY OPEN SINCE WE HAVE TO WRITE TO 2 REGIONS HERE.
  statement {
    actions = [
      "timestream:WriteRecords"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "timestream:DescribeEndpoints"
    ]
    resources = [
      "*"
    ]
  }
}

# allow role to be assumed by ecs and local saml users (for development)
data "aws_iam_policy_document" "kda_role_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["kinesisanalytics.amazonaws.com"]
    }

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:sts::${var.account_id}:assumed-role/${var.saml_role}/<email address>"
      ]
    }
  }
}
