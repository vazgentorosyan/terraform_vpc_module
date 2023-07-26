resource "aws_security_group" "public_sg" {
  name = "public_security_group"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge({
    Name = "${upper(var.product_name)}-PUBLIC-SG"
  }, var.tags)
}

resource "aws_security_group" "nat_sg" {
  name = "nat_security_group"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge({
    Name = "${upper(var.product_name)}-NAT-SG"
  }, var.tags)
}
