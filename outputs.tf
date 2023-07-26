output "ec2_public_ip" {
  value = aws_instance.public_ec2.public_ip
}
