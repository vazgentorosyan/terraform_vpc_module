variable "ec2_instances" {
  description = "Map or JSON string defining the EC2 instances to create"
  type        = any
  default     = {}
}

variable "instances" {
  description = "Alternative alias for ec2_instances"
  type        = any
  default     = null
}

variable "ami" {
  description = "Default AMI ID for instances"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "Default instance type"
  type        = string
  default     = "t3.micro"
}

variable "iam_instance_profile" {
  description = "Default IAM instance profile name for SSM"
  type        = string
  default     = null
}

variable "product_name" {
  description = "Product/project name prefix for tagging"
  type        = string
  default     = "project"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
