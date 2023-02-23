# create ci/cd user with access keys (for build system)
resource "aws_iam_user" "cicd" {
  name = "srv_${var.app}_${var.environment}_cicd"
}

resource "aws_iam_access_key" "cicd_keys" {
  user = aws_iam_user.cicd.name
}

# grant required permissions to deploy
data "aws_iam_policy_document" "cicd_policy" {
  
  statement {
    sid = "s3"

    actions = [
      "s3:Get*",
      "s3:Put*"
    ]

    resources = [
      var.kda_bucket_arn,
      "${var.kda_bucket_arn}/*"
    ]
  }

  statement {
    sid = "kms"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    resources = [
      var.kda_bucket_kms_arn
    ]
  }

  statement {
    sid = "kda"

    actions = [
      "kinesisanalytics:DescribeApplication",
      "kinesisanalytics:StartApplication",
      "kinesisanalytics:StopApplication",
      "kinesisanalytics:UpdateApplication"
    ]

    resources = [
      module.kda-agg.kda_app_arn
    ]
  }

  # Allow deployment of new lambda function
  statement {
    sid = "lambda"

    actions = [
      "lambda:UpdateFunctionCode"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_user_policy" "cicd_user_policy" {
  name   = "${var.app}_${var.environment}_cicd"
  user   = aws_iam_user.cicd.name
  policy = data.aws_iam_policy_document.cicd_policy.json
}

data "aws_ecr_repository" "ecr_app" {
  name = var.app
}

data "aws_ecr_repository" "ecr_loader" {
  name = "loader"
}

data "aws_ecr_repository" "ecr_load_test_loader" {
  name = "s3-loader-ltpd"
}

data "aws_ecr_repository" "ecr_load_test_reader" {
  name = "s3-reader-ltpd"
}

# The AWS keys for the CICD user to use in a build system
output "cicd_keys" {
  value = "terraform show -json | jq '.values.root_module.resources | .[] | select ( .address == \"aws_iam_access_key.cicd_keys\") | { AWS_ACCESS_KEY_ID: .values.id, AWS_SECRET_ACCESS_KEY: .values.secret }'"
}

# The URL for the docker image repo in ECR
output "docker_registry" {
  value = data.aws_ecr_repository.ecr_app.repository_url
}
