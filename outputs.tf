output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_subnet_ids" {
  description = "List of NAT subnet IDs"
  value       = module.vpc.nat_subnet_ids
}

output "ec2_public_ip" {
  description = "Public IP of the public EC2 instance"
  value       = try(module.ec2_instances.public_ips["public_instance"], null)
}

output "ec2_instance_ids" {
  description = "Map of all created EC2 instance names to IDs"
  value       = module.ec2_instances.instance_ids
}
