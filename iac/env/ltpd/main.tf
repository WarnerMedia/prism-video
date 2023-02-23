# main.tf
module "load_test_prod_destination_east_only" {
  source                 = "../../modules/load_test_prod_destination_east_only"
  app                    = var.app
  aws_profile            = var.aws_profile
  saml_role              = var.saml_role
  internal               = var.internal
  kpl_port               = var.kpl_port
  log_level              = var.log_level
  tags                   = var.tags
  common_environment     = var.common_environment
  s3_bucket_to_read_from = var.s3_bucket_to_read_from
  environment            = var.environment_us_east_1
  region                 = var.region_us_east_1
  vpc                    = var.vpc_us_east_1
  private_subnets        = var.private_subnets_us_east_1
  public_subnets         = var.public_subnets_us_east_1
  ecs_task_kpl_env       = var.ecs_task_kpl_east_env

}

terraform {
  backend "s3" {
    region  = "us-east-1"
    profile = ""
    bucket  = "tf-state-doppler-video"
    key     = "ltpd.terraform.tfstate"
  }
}
