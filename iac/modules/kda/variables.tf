variable "name" {}

variable "tags" {
  type = map(string)
}

variable "saml_role" {}

variable "account_id" {}

variable "s3_kda_arn" {}

variable "vpc" {}

variable "s3_object_key" {}

variable "kms_resource_arns" {
  type = list(string)
}

variable "kds_resource_arns" {
  type = list(string)
}

variable "environment_properties" {
  type = map(string)
}

variable "kda_parallelism" {}

variable "kda_parallelism_per_kpu" {}

variable "private_subnets" {}

variable "log_level" {}

variable "kda_bucket_arn" {}

variable "private_subnet_range" {
  type = map(string)
  default = {"192.168.0.0/16"}
}

variable "vpn_ip_range" {
  type = map(string)
  default = {"192.168.0.0/16"}
}