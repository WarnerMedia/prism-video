resource "aws_lambda_event_source_mapping" "lambda_kds" {
  enabled                            = "true"
  event_source_arn                   = var.kinesis_stream_arn
  function_name                      = var.lambda_function_arn
  
  batch_size                         = var.batch_size
  maximum_batching_window_in_seconds = var.maximum_batching_window_in_seconds
  starting_position                  = var.starting_position
  maximum_retry_attempts             = var.maximum_retry_attempts
  maximum_record_age_in_seconds      = var.maximum_record_age_in_seconds
  bisect_batch_on_function_error     = var.bisect_batch_on_function_error
  parallelization_factor             = var.parallelization_factor
  destination_config {
    on_failure {
      destination_arn = var.failed_sqs_arn
    }
  }
}
