module "us_east_1" {
  source = "../../modules/ecr"
  providers = {
    aws = aws
  }
  app                  = var.app
  image_tag_mutability = var.image_tag_mutability
}

module "us_west_2" {
  source = "../../modules/ecr"
  providers = {
    aws = aws.us-west-2
  }
  app                  = var.app
  image_tag_mutability = var.image_tag_mutability
}

module "loader" {
  source = "../../modules/ecr"
  providers = {
    aws = aws
  }
  app                  = "loader"
  image_tag_mutability = var.image_tag_mutability
}

module "s3-loader-ltpd" {
  source = "../../modules/ecr"
  providers = {
    aws = aws
  }
  app                  = "s3-loader-ltpd"
  image_tag_mutability = var.image_tag_mutability
}

module "s3-reader-ltpd" {
  source = "../../modules/ecr"
  providers = {
    aws = aws
  }
  app                  = "s3-reader-ltpd"
  image_tag_mutability = var.image_tag_mutability
}
