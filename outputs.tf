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

output "vpc_endpoint_ids" {
  description = "Map of created VPC interface endpoint names to IDs"
  value       = module.vpc.endpoint_ids
}

output "ec2_public_ip" {
  description = "Public IP of the public EC2 instance"
  value       = try(module.ec2_instances[0].public_ips["public_instance"], null)
}

output "ec2_instance_ids" {
  description = "Map of all created EC2 instance names to IDs"
  value       = try(module.ec2_instances[0].instance_ids, {})
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = try(module.eks[0].cluster_name, null)
}

output "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = try(module.eks[0].cluster_endpoint, null)
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = try(module.eks[0].cluster_security_group_id, null)
}
