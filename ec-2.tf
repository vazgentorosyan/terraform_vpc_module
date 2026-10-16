module "ec2_instances" {
  source = "./modules/ec2"

  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
  product_name         = var.product_name
  tags                 = var.tags

  ec2_instances = {
    public_instance = {
      subnet-id                   = module.vpc.public_subnet_ids[0]
      instance_name               = "${var.product_name}-public-ec2"
      associate_public_ip_address = true
      vpc_security_group_ids      = [aws_security_group.public_sg.id]
    }
    nat_instance = {
      subnet-id                   = module.vpc.nat_subnet_ids[0]
      instance_name               = "${var.product_name}-nat-ec2"
      associate_public_ip_address = false
      vpc_security_group_ids      = [aws_security_group.nat_sg.id]
    }
    private_instance = {
      subnet-id                   = module.vpc.private_subnet_ids[0]
      instance_name               = "${var.product_name}-private-ec2"
      associate_public_ip_address = false
      vpc_security_group_ids      = [aws_security_group.private_sg.id]
    }
  }
}
