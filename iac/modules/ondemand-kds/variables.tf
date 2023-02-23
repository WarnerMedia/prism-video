variable "name" {}

variable "tags" {
  type = map(string)
}

variable "detailed_shard_level_metrics" {
  type        = list(string)
  description = "shard level metrics"
}
