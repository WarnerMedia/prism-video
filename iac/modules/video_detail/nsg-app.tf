resource "aws_security_group" "nsg_lb_app" {
  name        = "${local.ns}-lb-app"
  description = "Allow connections from external resources while limiting connections from ${local.ns}-lb to internal resources"
  vpc_id      = var.vpc

  tags = var.tags
}

resource "aws_security_group" "nsg_task_app" {
  name        = "${local.ns}-task-app"
  description = "Limit connections from internal resources while allowing ${local.ns}-task to connect to all external resources"
  vpc_id      = var.vpc

  tags = var.tags
}

# Rules for the LB (Targets the task SG)
resource "aws_security_group_rule" "nsg_lb_egress_rule_app" {
  description              = "Only allow SG ${local.ns}-lb to connect to ${local.ns}-task on port ${var.container_port_app}"
  type                     = "egress"
  from_port                = var.container_port_app
  to_port                  = var.container_port_app
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nsg_task_app.id

  security_group_id = aws_security_group.nsg_lb_app.id
}

# Rules for the TASK (Targets the LB SG)
resource "aws_security_group_rule" "nsg_task_ingress_rule_app" {
  description              = "Only allow connections from SG ${local.ns}-lb on port ${var.container_port_app}"
  type                     = "ingress"
  from_port                = var.container_port_app
  to_port                  = var.container_port_app
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nsg_lb_app.id

  security_group_id = aws_security_group.nsg_task_app.id
}

resource "aws_security_group_rule" "nsg_task_egress_rule_app" {
  description = "Allows task to establish connections to all resources"
  type        = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nsg_task_app.id
}
