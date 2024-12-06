output "instance_amd64_id" {
  value = aws_instance.buildkit-amd64[0].id
}

output "instance_arm64_id" {
  value = aws_instance.buildkit-arm64[0].id
}
