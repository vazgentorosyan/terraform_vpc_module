resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.product_name}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge({
    Name = "${upper(var.product_name)}-EC2-SSM-ROLE"
  }, var.tags)
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "${var.product_name}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name

  tags = merge({
    Name = "${upper(var.product_name)}-EC2-SSM-PROFILE"
  }, var.tags)
}
