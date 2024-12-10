variable "iam_instance_profile" {
  type = string
}

variable "ts_auth_key" {
  type      = string
  sensitive = true
}

variable "subnet_ids" {
  type = set(string)
}

variable "security_group_id" {
  type = string
}

variable "route_table_association" {
  type = any
}
