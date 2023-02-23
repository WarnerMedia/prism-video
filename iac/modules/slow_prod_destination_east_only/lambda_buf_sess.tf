resource "aws_lambda_function" "lambda_buf_sess" {
  filename      = "kds_timestream_buf_sess.zip"
  function_name = "${local.ns}-kds-timestream-buf-sess"
  role          = aws_iam_role.iam_lambda_buf_sess.arn
  handler       = "kds_timestream_buf_sess"
  runtime       = "go1.x"
  timeout       = 45

  environment {
    variables = var.kds_timestream_buf_sess_lambda_env
  }
}

resource "aws_iam_role" "iam_lambda_buf_sess" {
  name               = "${local.ns}-lambda_buf_sess"
  assume_role_policy = data.aws_iam_policy_document.lambda_buf_sess_role_assume_role_policy.json
  tags               = var.tags
}

# assigns the app policy
resource "aws_iam_role_policy" "lambda_buf_sess_policy" {
  name   = "${local.ns}-lambda_buf_sess"
  role   = aws_iam_role.iam_lambda_buf_sess.id
  policy = data.aws_iam_policy_document.lambda_buf_sess_policy.json
}

data "aws_iam_policy_document" "lambda_buf_sess_policy" {

  # use of sqs for dlq
  statement {
    actions = [
      "sqs:*",
    ]
    resources = ["*"]
  }

  # use of kds
  statement {
    actions = [
      "kinesis:*",
    ]
    resources = [
      module.kds-sess.kinesis_data_stream_arn,
      "${module.kds-sess.kinesis_data_stream_arn}/*"
    ]
  }

  # use of the sess kms encryption key
  statement {
    actions = [
      "kms:*",
    ]
    resources = ["*"]
  }

  # to allow the writing of cw metric data
  statement {
    actions = [
      "cloudwatch:*"
    ]
    resources = ["*"]
  }
  # allow to write to logs
  statement {
    actions = [
      "logs:*"
    ]
    resources = ["*"]
  }

  # access to write to timestream tables
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
data "aws_iam_policy_document" "lambda_buf_sess_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${var.saml_role}/<email address>"
      ]
    }
  }
}
