output "iam_role_name" {
  value = aws_iam_role.buildkit.name
}

output "iam_instance_profile" {
  value = aws_iam_instance_profile.buildkit.name
}