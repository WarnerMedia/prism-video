resource "aws_security_group" "nsg_task_reader" {
  name        = "${local.ns}-task-reader"
  description = "Limit connections from internal resources while allowing ${local.ns}-task to connect to all external resources"
  vpc_id      = var.vpc

  tags = var.tags
}

resource "aws_security_group_rule" "nsg_task_egress_rule_reader" {
  description = "Allows task to establish connections to all resources"
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nsg_task_reader.id
}
