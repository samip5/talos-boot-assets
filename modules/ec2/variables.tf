variable "iam_instance_profile" {
  description = "The IAM instance profile for EC2"
  type        = string
}

variable "ts_auth_key_amd64" {
  description = "Tailscale auth key for amd64 instance"
  type        = string
  sensitive   = true
}

variable "ts_auth_key_arm64" {
  description = "Tailscale auth key for arm64 instance"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}
