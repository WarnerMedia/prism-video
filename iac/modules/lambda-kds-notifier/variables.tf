variable "lambda_function_arn" {}
variable "kinesis_stream_arn" {}
variable "failed_sqs_arn" {}

variable "batch_size" {}                         # "100"
variable "maximum_batching_window_in_seconds" {} # "5"
variable "starting_position" {}                  # "LATEST"
variable "maximum_retry_attempts" {}             # "5"
variable "maximum_record_age_in_seconds" {}      # "-1"
variable "bisect_batch_on_function_error" {}     # "true"
variable "parallelization_factor" {}             # "10"
