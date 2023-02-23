# adds an https listener to the load balancer
# (delete this file if you only want http)

# The port to listen on for HTTPS, always use 443
variable "https_port" {
  default = "443"
}

resource "aws_alb_listener" "https_app" {
  load_balancer_arn = aws_alb.app.id
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app.id
  }
}

resource "aws_security_group_rule" "ingress_lb_https_app" {
  type              = "ingress"
  description       = "HTTPS"
  from_port         = var.https_port
  to_port           = var.https_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nsg_lb_app.id
}

locals {
  subdomain = "${var.environment}.${var.hosted_zone}"
}

resource "aws_route53_record" "app" {
  zone_id = var.route53_zone_id
  type    = "A"
  name    = local.subdomain

  alias {
    name                   = aws_alb.app.dns_name
    zone_id                = aws_alb.app.zone_id
    evaluate_target_health = true
  }
}

//cert matches cname
resource "aws_acm_certificate" "cert" {
  domain_name       = aws_route53_record.app.name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  zone_id = var.route53_zone_id
  records = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

resource "aws_lb_listener_certificate" "cert" {
  listener_arn    = aws_alb_listener.https_app.arn
  certificate_arn = aws_acm_certificate.cert.arn
}

// additional cert for common subdomain used in all regions
resource "aws_acm_certificate" "additional_cert" {
  domain_name       = var.common_subdomain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "additional_cert_validation" {
  name            = tolist(aws_acm_certificate.additional_cert.domain_validation_options)[0].resource_record_name
  type            = tolist(aws_acm_certificate.additional_cert.domain_validation_options)[0].resource_record_type
  zone_id         = var.route53_zone_id
  records         = [tolist(aws_acm_certificate.additional_cert.domain_validation_options)[0].resource_record_value]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "additional_cert" {
  certificate_arn         = aws_acm_certificate.additional_cert.arn
  validation_record_fqdns = [aws_route53_record.additional_cert_validation.fqdn]
}


resource "aws_lb_listener_certificate" "additional_cert" {
  listener_arn    = aws_alb_listener.https_app.arn
  certificate_arn = aws_acm_certificate.additional_cert.arn
}
