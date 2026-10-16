resource "aws_instance" "public_ec2" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.PublicSubnet[0].id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name = upper("${var.product_name}-PUBLIC-EC2")
  }
  lifecycle {
    ignore_changes = [vpc_security_group_ids, tags]
  }
}

resource "aws_instance" "nat_ec2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.NatSubnet[0].id
  vpc_security_group_ids = [aws_security_group.nat_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm_profile.name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = {
    Name = upper("${var.product_name}-NAT-EC2")
  }
  lifecycle {
    ignore_changes = [vpc_security_group_ids, tags]
  }
}
