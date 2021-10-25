output "ec2_public_ip" {
  value = aws_instance.nat_ec2.public_ip
}
