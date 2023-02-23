resource "aws_security_group" "nsg_kda" {
  name        = "${var.name}-sg"
  description = "Allow inbound and outbound traffic to KDA from VPC CIDR"
  vpc_id      = var.vpc

  tags = var.tags
}

# Allow incoming connections from vpn to kda
resource "aws_security_group_rule" "nsg_kda_vpn" {
  description = "Allow connections from the VPN to KDA"
  type        = "ingress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = var.vpn_ip_range

  security_group_id = aws_security_group.nsg_kda.id
}

# Allow incoming connections from vpc to kda
resource "aws_security_group_rule" "nsg_kda_vpc" {
  description = "Allow connections from the VPC to KDA"
  type        = "ingress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = var.private_subnet_range

  security_group_id = aws_security_group.nsg_kda.id
}

# Allow all outgoing connections
resource "aws_security_group_rule" "nsg_kda_egress" {
  description      = "Allow all outgoing connections"
  type             = "egress"
  from_port        = "0"
  to_port          = "0"
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.nsg_kda.id
}
