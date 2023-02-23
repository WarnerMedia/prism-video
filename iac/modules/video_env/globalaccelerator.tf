# Main GA Accelerator

resource "aws_globalaccelerator_accelerator" "video" {
  name            = "${var.app}-${var.common_environment}"
  ip_address_type = "IPV4"
  enabled         = true
  tags            = var.tags

  attributes {
    flow_logs_enabled   = false
    flow_logs_s3_bucket = aws_s3_bucket.ga_flow_logs.id
    flow_logs_s3_prefix = "flow-logs/"
  }
}

variable "ga_flow_logs_expiration_days" {
  default = "7"
}

# bucket for storing GA flow logs
resource "aws_s3_bucket" "ga_flow_logs" {
  bucket        = "${var.app}-${var.common_environment}-ga-flow-logs"
  tags          = var.tags
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_acl" "ga_flow_logs" {
  bucket = aws_s3_bucket.ga_flow_logs.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "ga_flow_logs" {
  bucket = aws_s3_bucket.ga_flow_logs.id

  rule {
    id     = "expiration"
    status = "Enabled"

    expiration {
      days = var.ga_flow_logs_expiration_days
    }
  }

  rule {
    id     = "multipart"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }

  rule {
    id     = "intelligent-tiering"
    status = "Enabled"
    transition {
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ga_flow_logs" {
  bucket = aws_s3_bucket.ga_flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# Main GA Listener

resource "aws_globalaccelerator_listener" "video" {
  accelerator_arn = aws_globalaccelerator_accelerator.video.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

# Endpoint groups
# As we add more environments, we'll need to add them here to be a part of ga

resource "aws_globalaccelerator_endpoint_group" "video_destination" {
  depends_on              = [module.destination.lb_arn]
  listener_arn            = aws_globalaccelerator_listener.video.id
  endpoint_group_region   = "us-east-1"
  traffic_dial_percentage = 100

  // us east 1
  endpoint_configuration {
    client_ip_preservation_enabled = true
    endpoint_id                    = module.destination.lb_arn
    weight                         = 100
  }
}

resource "aws_globalaccelerator_endpoint_group" "video_source" {
  depends_on              = [module.source.lb_arn]
  listener_arn            = aws_globalaccelerator_listener.video.id
  endpoint_group_region   = "us-west-2"
  traffic_dial_percentage = 100

  // us east 1
  endpoint_configuration {
    client_ip_preservation_enabled = true
    endpoint_id                    = module.source.lb_arn
    weight                         = 100
  }
}
