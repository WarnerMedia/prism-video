variable "name" {}

variable "tags" {
  type = map(string)
}

variable "firehose_buffer_size" {}

variable "firehose_buffer_interval" {}

variable "kds_arn" {}

variable "kms_kds_arn" {}

variable "kms_s3_arn" {}

variable "s3_target_arn" {}

variable "prefix" {}
