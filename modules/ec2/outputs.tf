output "instances" {
  description = "Map of created EC2 instance details"
  value = {
    for k, v in aws_instance.this : k => {
      id                     = v.id
      arn                    = v.arn
      public_ip              = v.public_ip
      private_ip             = v.private_ip
      subnet_id              = v.subnet_id
      vpc_security_group_ids = v.vpc_security_group_ids
    }
  }
}

output "instance_ids" {
  description = "Map of instance names to IDs"
  value       = { for k, v in aws_instance.this : k => v.id }
}

output "public_ips" {
  description = "Map of instance names to public IPs"
  value       = { for k, v in aws_instance.this : k => v.public_ip if v.public_ip != "" }
}

output "private_ips" {
  description = "Map of instance names to private IPs"
  value       = { for k, v in aws_instance.this : k => v.private_ip }
}
