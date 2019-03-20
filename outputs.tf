
output "connect" {
  value = "ssh ${var.username}@${aws_instance.sshserver.public_dns}"
}