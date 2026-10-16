module "vpc" {
  source = "./modules/vpc"

  product_name = var.product_name
  cidr_block   = var.cidr_block
  public_cidr  = var.public_cidr
  private_cidr = var.private_cidr
  nat_cidr     = var.nat_cidr
  tags         = var.tags
}

########################################
# State migration blocks (preserves state)
########################################

moved {
  from = aws_vpc.vpc
  to   = module.vpc.aws_vpc.vpc
}

moved {
  from = aws_eip.elastic_ip1
  to   = module.vpc.aws_eip.elastic_ip1
}

moved {
  from = aws_internet_gateway.main_gateway
  to   = module.vpc.aws_internet_gateway.main_gateway
}

moved {
  from = aws_subnet.PublicSubnet
  to   = module.vpc.aws_subnet.PublicSubnet
}

moved {
  from = aws_route_table.igw_rt
  to   = module.vpc.aws_route_table.igw_rt
}

moved {
  from = aws_route.public_igw_route
  to   = module.vpc.aws_route.public_igw_route
}

moved {
  from = aws_route_table_association.igw_route_tb_assoc
  to   = module.vpc.aws_route_table_association.igw_route_tb_assoc
}

moved {
  from = aws_subnet.NatSubnet
  to   = module.vpc.aws_subnet.NatSubnet
}

moved {
  from = aws_nat_gateway.nat_gateway
  to   = module.vpc.aws_nat_gateway.nat_gateway
}

moved {
  from = aws_route_table.nat_rt
  to   = module.vpc.aws_route_table.nat_rt
}

moved {
  from = aws_route.nat_gw_route
  to   = module.vpc.aws_route.nat_gw_route
}

moved {
  from = aws_route_table_association.nat_gw_assoc
  to   = module.vpc.aws_route_table_association.nat_gw_assoc
}

moved {
  from = aws_subnet.PrivateSubnet
  to   = module.vpc.aws_subnet.PrivateSubnet
}

moved {
  from = aws_route_table.private_rt
  to   = module.vpc.aws_route_table.private_rt
}

moved {
  from = aws_route_table_association.private_rt_assoc
  to   = module.vpc.aws_route_table_association.private_rt_assoc
}
