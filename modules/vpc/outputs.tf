output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.vpc.arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.PublicSubnet[*].id
}

output "nat_subnet_ids" {
  description = "List of IDs of NAT subnets"
  value       = aws_subnet.NatSubnet[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.PrivateSubnet[*].id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main_gateway.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gateway.id
}

output "elastic_ip" {
  description = "The Elastic IP allocated for the NAT Gateway"
  value       = aws_eip.elastic_ip1.public_ip
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = data.aws_availability_zones.available.names
}

output "endpoint_ids" {
  description = "Map of created VPC interface endpoint names to IDs"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

output "endpoint_security_group_id" {
  description = "Security group ID for VPC interface endpoints"
  value       = try(aws_security_group.vpc_endpoints_sg[0].id, null)
}

