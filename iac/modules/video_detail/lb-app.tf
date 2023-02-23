# note that this creates the alb, target group, and access logs
# the listeners are defined in lb-http.tf and lb-https.tf
# delete either of these if your app doesn't need them
# but you need at least one

# Whether the application is available on the public internet,
# also will determine which subnets will be used (public or private)
variable "internal" {
  default = true
}

# The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused
variable "deregistration_delay" {
  default = "30"
}

# How often to check the liveliness of the container
variable "health_check_interval" {
  default = "30"
}

# How long to wait for the response on the health check path
variable "health_check_timeout" {
  default = "10"
}

# What HTTP response code to listen for
variable "health_check_matcher" {
  default = "200"
}

variable "lb_access_logs_expiration_days" {
  default = "3"
}

resource "aws_alb" "app" {
  name = "${local.ns}-app"

  # launch lbs in public or private subnets based on "internal" variable
  internal = var.internal
  subnets = split(
    ",",
    var.internal == true ? var.private_subnets : var.public_subnets,
  )
  security_groups = [aws_security_group.nsg_lb_app.id]
  tags            = var.tags

  # enable access logs in order to get support from aws
  access_logs {
    enabled = true
    bucket  = aws_s3_bucket.lb_access_logs_app.bucket
  }
}

resource "aws_alb_target_group" "app" {
  name                 = "${local.ns}-app"
  port                 = var.lb_port
  protocol             = var.lb_protocol
  vpc_id               = var.vpc
  target_type          = "ip"
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.health_check_app
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  tags = var.tags
}

data "aws_elb_service_account" "app" {
}

# bucket for storing ALB access logs
resource "aws_s3_bucket" "lb_access_logs_app" {
  bucket        = "${local.ns}-lb-access-logs-app"
  tags          = var.tags
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_acl" "lb_access_logs_app" {
  bucket = aws_s3_bucket.lb_access_logs_app.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "lb_access_logs_app" {
  bucket = aws_s3_bucket.lb_access_logs_app.id

  rule {
    id     = "expiration"
    status = "Enabled"

    expiration {
      days = var.lb_access_logs_expiration_days
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

resource "aws_s3_bucket_server_side_encryption_configuration" "lb_access_logs_app" {
  bucket = aws_s3_bucket.lb_access_logs_app.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}



# give load balancing service access to the bucket
resource "aws_s3_bucket_policy" "lb_access_logs_app" {
  bucket = aws_s3_bucket.lb_access_logs_app.id

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.lb_access_logs_app.arn}",
        "${aws_s3_bucket.lb_access_logs_app.arn}/*"
      ],
      "Principal": {
        "AWS": [ "${data.aws_elb_service_account.app.arn}" ]
      }
    }
  ]
}
POLICY
}

# The load balancer DNS name
output "lb_dns_app" {
  value = aws_alb.app.dns_name
}
