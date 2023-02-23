module "lambda_s3_us_east_1" {
  source = "../../modules/s3-lambda"
  providers = {
    aws = aws
  }
  app                  = "${var.app}-useast1"
  tags = var.tags
}

module "lambda_s3_us_west_2" {
  source = "../../modules/s3-lambda"
  providers = {
    aws = aws.us-west-2
  }
  app                  = "${var.app}-uswest2"
  tags = var.tags
}

output "lambda_s3_bucket_us_east_1" {
    value = module.lambda_s3_us_east_1.lambda_s3_bucket
}

output "lambda_s3_kms_bucket_us_east_1" {
    value = module.lambda_s3_us_east_1.lambda_s3_kms_arn
}

output "lambda_s3_bucket_us_west_2" {
    value = module.lambda_s3_us_west_2.lambda_s3_bucket
}

output "lambda_s3_kms_bucket_us_west_2" {
    value = module.lambda_s3_us_west_2.lambda_s3_kms_arn
}