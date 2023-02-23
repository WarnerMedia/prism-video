resource "aws_kinesis_stream_consumer" "kds_consumer" {
  name       = var.name
  stream_arn = var.stream_arn
}

output "kds_consumer_arn" {
  value = aws_kinesis_stream_consumer.kds_consumer.arn
}
