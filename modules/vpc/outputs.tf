output "vpc_id" {
  value = aws_vpc.buildkit.id
}

output "subnet_ids" {
  value = aws_subnet.buildkit[*].id
}

output "route_table_association" {
  value      = {}
  depends_on = [aws_route_table_association.buildkit]
}
