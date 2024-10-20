output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "instance_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}

output "instance_public_dns" {
  value = aws_instance.ec2_instance.public_dns
}

output "private_key" {
  value       = tls_private_key.ssh_keygen.private_key_pem
  sensitive   = true  # Sensitive value
}
