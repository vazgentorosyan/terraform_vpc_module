data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_eip" "elastic_ip1" {
    vpc      = true
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({
    Name = "${upper(var.product_name)}-VPC"
  }, var.tags)
}

########################################
####### Public subnet resources ########
########################################

resource "aws_subnet" "PublicSubnet" {
  count = length(data.aws_availability_zones.available.names)

  cidr_block              = cidrsubnet(var.public_cidr, 6, count.index)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = merge({
    Name = "PUBLIC-SUBNET-${upper(data.aws_availability_zones.available.names[count.index])}"
  }, var.tags)
}

resource "aws_internet_gateway" "main_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = merge({
    Name = "${upper(var.product_name)}-VPC-IGW"
  }, var.tags)
}

resource "aws_route_table" "igw_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${upper(var.product_name)}-RT-PUBLIC"
  }, var.tags)
}

resource "aws_route" "public_igw_route" {
  route_table_id         = aws_route_table.igw_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_gateway.id
}

resource "aws_route_table_association" "igw_route_tb_assoc" {
  count = length(aws_subnet.PublicSubnet)

  route_table_id = aws_route_table.igw_rt.id
  subnet_id      = element(aws_subnet.PublicSubnet.*.id, count.index)
}

#####################################
####### Nat subnet resources ########
#####################################

resource "aws_subnet" "NatSubnet" {
  count = length(data.aws_availability_zones.available.names)

  cidr_block              = cidrsubnet(var.nat_cidr, 6, count.index)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = merge({
    Name = "NAT-SUBNET-${upper(data.aws_availability_zones.available.names[count.index])}"
  }, var.tags)
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip1.id
  subnet_id = aws_subnet.NatSubnet.0.id
  tags = merge({
    Name = "NAT-SUBNET-${upper(aws_subnet.NatSubnet.0.availability_zone)}"
  }, var.tags)
}

resource "aws_route_table" "nat_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${upper(var.product_name)}-RT-NAT"
  }, var.tags)
}

resource "aws_route" "nat_gw_route" {
  route_table_id         = aws_route_table.nat_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "nat_gw_assoc" {
  count          = length(aws_subnet.NatSubnet)
  subnet_id      = element(aws_subnet.NatSubnet.*.id, count.index)
  route_table_id = aws_route_table.nat_rt.id
}


#########################################
####### Private subnet resources ########
#########################################


resource "aws_subnet" "PrivateSubnet" {
  count = length(data.aws_availability_zones.available.names)

  cidr_block              = cidrsubnet(var.private_cidr, 6, count.index)
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = merge({
    Name = "PRIVATE-SUBNET-${upper(data.aws_availability_zones.available.names[count.index])}"
  }, var.tags)
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = merge({
    Name = "${upper(var.product_name)}-RT-PRIVATE"
  }, var.tags)
}

resource "aws_route_table_association" "private_rt_assoc" {
  count          = length(aws_subnet.PrivateSubnet)
  subnet_id      = element(aws_subnet.PrivateSubnet.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}
