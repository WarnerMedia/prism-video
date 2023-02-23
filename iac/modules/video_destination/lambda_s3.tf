resource "aws_lambda_function" "lambda_s3" {
  filename      = "late_s3_metrics.zip"
  function_name = "${local.ns}-late-s3-metrics"
  role          = aws_iam_role.iam_lambda_s3.arn
  handler       = "late_s3_metrics"
  runtime       = "go1.x"
  timeout       = 15

  environment {
    variables = var.late_arriving_lambda_env
  }
}

resource "aws_iam_role" "iam_lambda_s3" {
  name               = "${local.ns}-lambda_s3"
  assume_role_policy = data.aws_iam_policy_document.lambda_s3_role_assume_role_policy.json
  tags               = var.tags
}

# assigns the app policy
resource "aws_iam_role_policy" "lambda_s3_policy" {
  name   = "${local.ns}-lambda_s3"
  role   = aws_iam_role.iam_lambda_s3.id
  policy = data.aws_iam_policy_document.lambda_s3_policy.json
}

data "aws_iam_policy_document" "lambda_s3_policy" {

  # use of s3 buckets
  statement {
    actions = [
      "s3:*",
    ]
    resources = ["*"]
  }

  # use of the raw kms encryption key
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

  statement {
    actions = [
      "logs:*"
    ]
    resources = ["*"]
  }
}

data "aws_caller_identity" "current" {
}

# allow role to be assumed by ecs and local saml users (for development)
data "aws_iam_policy_document" "lambda_s3_role_assume_role_policy" {
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
