resource "aws_instance" "public_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.PublicSubnet.0.id
  key_name = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true
  security_groups = [aws_security_group.public_sg.id]

  tags = {
    Name = upper("${var.product_name}-PUBLIC-EC2")
  }
  lifecycle {
    ignore_changes = [security_groups, tags]
  }
}

resource "aws_instance" "nat_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.NatSubnet.0.id
  key_name = aws_key_pair.key_pair.key_name
  security_groups = [aws_security_group.nat_sg.id]

  tags = {
    Name = upper("${var.product_name}-NAT-EC2")
  }
  lifecycle {
    ignore_changes = [security_groups, tags]
  }
}
