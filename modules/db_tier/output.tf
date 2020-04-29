output "instance_ip_address" {
  value = aws_instance.mongodb_instance.private_ip
}
