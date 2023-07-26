variable "product_name" {
  default = "test-backend-project"
}
variable "aws_region" {
  default = "us-east-1"
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
