module "kda_s3_us_east_1" {
  source = "../../modules/s3-kda"
  providers = {
    aws = aws
  }
  app                  = "${var.app}-useast1"
  tags = var.tags
}

module "kda_s3_us_west_2" {
  source = "../../modules/s3-kda"
  providers = {
    aws = aws.us-west-2
  }
  app                  = "${var.app}-uswest2"
  tags = var.tags
}

output "kda_s3_bucket_us_east_1" {
    value = module.kda_s3_us_east_1.kda_s3_bucket
}

output "kda_s3_kms_bucket_us_east_1" {
    value = module.kda_s3_us_east_1.kda_s3_kms_arn
}

output "kda_s3_bucket_us_west_2" {
    value = module.kda_s3_us_west_2.kda_s3_bucket
}

output "kda_s3_kms_bucket_us_west_2" {
    value = module.kda_s3_us_west_2.kda_s3_kms_arn
}