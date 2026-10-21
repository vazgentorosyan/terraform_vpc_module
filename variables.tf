variable "product_name" {
  default = "test-backend-project"
}
variable "aws_region" {
  default = "eu-north-1"
}
variable "cidr_block" {
  type    = string
  default = "10.152.0.0/16"
}

variable "public_cidr" {
  default = "10.152.0.0/18"
}

variable "private_cidr" {
  default = "10.152.64.0/18"
}

variable "nat_cidr" {
  default = "10.152.128.0/18"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "tags" {
  type = map(string)
  default = {
    Terraform = true
  }
}

variable "ingress_rules" {
  type = list(map(string))
  default = [{
    port        = 443
    description = "HTTPS"
    },
    {
      port        = 80
      description = "HTTP"
    },
    {
      port        = 22
      description = "SSH"
    },
    {
      port        = 3389
      description = "RDP"
  }]
}

variable "create_eks" {
  description = "Controls if the EKS cluster should be created by default"
  type        = bool
  default     = false
}

variable "create_ec2" {
  description = "Controls if the EC2 demo instances should be created"
  type        = bool
  default     = false
}
