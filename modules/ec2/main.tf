locals {
  instances = var.ec2_instances
}

resource "aws_instance" "this" {
  for_each = local.instances

  ami                         = try(each.value.ami, var.ami)
  instance_type               = try(each.value.instance_type, each.value["instance-type"], var.instance_type)
  subnet_id                   = try(each.value.subnet_id, each.value["subnet-id"])
  associate_public_ip_address = try(each.value.associate_public_ip_address, each.value["associate-public-ip-address"], false)
  vpc_security_group_ids      = try(each.value.vpc_security_group_ids, each.value["vpc-security-group-ids"], try([each.value.security_group_id], []))
  iam_instance_profile        = try(each.value.iam_instance_profile, each.value["iam-instance-profile"], var.iam_instance_profile)

  metadata_options {
    http_endpoint               = try(each.value.metadata_options.http_endpoint, "enabled")
    http_tokens                 = try(each.value.metadata_options.http_tokens, "required")
    http_put_response_hop_limit = try(each.value.metadata_options.http_put_response_hop_limit, 2)
  }

  tags = merge(
    {
      Name = upper(try(each.value.instance_name, each.value["instance-name"], "${var.product_name}-${each.key}"))
    },
    var.tags,
    try(each.value.tags, {})
  )

  lifecycle {
    ignore_changes = [vpc_security_group_ids, tags]
  }
}
