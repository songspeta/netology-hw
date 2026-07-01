output "subnet_id" {
  description = "Subnet ID"
  value       = yandex_vpc_subnet.develop.id
}

output "subnet_name" {
  description = "Subnet name"
  value       = yandex_vpc_subnet.develop.name
}

output "network_id" {
  description = "Network ID"
  value       = var.network_id
}