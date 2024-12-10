output "instance_amd64_id" {
  value = data.aws_instances.amd64.ids[0]
}

output "instance_arm64_id" {
  value = data.aws_instances.arm64.ids[0]
}
