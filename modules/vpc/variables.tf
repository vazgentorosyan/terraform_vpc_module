variable "product_name" {
  description = "Product/project name prefix for resource naming and tagging"
  type        = string
  default     = "project"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.152.0.0/16"
}

variable "public_cidr" {
  description = "Base CIDR block for public subnets"
  type        = string
  default     = "10.152.0.0/18"
}

variable "private_cidr" {
  description = "Base CIDR block for private subnets"
  type        = string
  default     = "10.152.64.0/18"
}

variable "nat_cidr" {
  description = "Base CIDR block for NAT subnets"
  type        = string
  default     = "10.152.128.0/18"
}

variable "tags" {
  description = "Tags to attach to VPC resources"
  type        = map(string)
  default     = {}
}
