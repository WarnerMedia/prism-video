# creates an application role that the container/task runs as
resource "aws_iam_role" "reader_role" {
  name               = "${local.ns}-reader"
  assume_role_policy = data.aws_iam_policy_document.reader_role_assume_role_policy.json
  tags               = var.tags
}

# assigns the app policy
resource "aws_iam_role_policy" "reader_policy" {
  name   = "${local.ns}-reader"
  role   = aws_iam_role.reader_role.id
  policy = data.aws_iam_policy_document.reader_policy.json
}

data "aws_iam_policy_document" "reader_policy" {

  # access to s3 buckets
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

  # access to the sqs sendmessage
  statement {
    actions = [
      "sqs:*"
    ]
    resources = ["*"]
  }

  # to allow the writing of cw metric data
  statement {
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
  }

  # to allow access to cw agent rule
  statement {
    actions = [
      "ssm:GetParameter"
    ]
    resources = ["*"]
  }
}

# allow role to be assumed by ecs and local saml users (for development)
data "aws_iam_policy_document" "reader_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${var.saml_role}/<email address>"
      ]
    }
  }
}
