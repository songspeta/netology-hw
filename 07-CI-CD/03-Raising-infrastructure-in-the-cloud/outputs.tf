# outputs.tf

output "alb_public_ip" {
  description = "Public IP address of the Application Load Balancer"
  value       = yandex_alb_load_balancer.web_lb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

output "web_servers_private_ips" {
  description = "Private IPs of web servers"
  value = [
    yandex_compute_instance.web_a.network_interface[0].ip_address,
    yandex_compute_instance.web_b.network_interface[0].ip_address
  ]
}

output "db_private_ip" {
  description = "Private IP of the database server"
  value = yandex_compute_instance.db.network_interface[0].ip_address
}