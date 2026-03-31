# =============================================================================
# OUTPUTS
# =============================================================================

# --- Bastion  ---
output "bastion_public_ip" {
  description = "Public IP address of Bastion host"
  value       = yandex_compute_instance.bastion["bastion-a-1"].network_interface[0].nat_ip_address
}

output "bastion_private_ip" {
  description = "Private IP address of Bastion host"
  value       = yandex_compute_instance.bastion["bastion-a-1"].network_interface[0].ip_address
}

# --- Web Servers ---
output "web_servers" {
  description = "Web servers information"
  value = {
    for name, instance in yandex_compute_instance.web : name => {
      zone        = instance.zone
      private_ip  = instance.network_interface[0].ip_address
      hostname    = instance.hostname
    }
  }
}

output "web_a_private_ip" {
  description = "Private IP of Web server A"
  value       = yandex_compute_instance.web["web-a-1"].network_interface[0].ip_address
}

output "web_b_private_ip" {
  description = "Private IP of Web server B"
  value       = yandex_compute_instance.web["web-b-1"].network_interface[0].ip_address
}

# --- Monitoring  ---
output "prometheus_private_ip" {
  description = "Private IP address of Prometheus"
  value       = yandex_compute_instance.prometheus["prometheus-a-1"].network_interface[0].ip_address
}

output "grafana_public_ip" {
  description = "Public IP address of Grafana"
  value       = yandex_compute_instance.grafana["grafana-a-1"].network_interface[0].nat_ip_address
}

output "grafana_private_ip" {
  description = "Private IP address of Grafana"
  value       = yandex_compute_instance.grafana["grafana-a-1"].network_interface[0].ip_address
}

# --- Logging  ---
output "elasticsearch_private_ip" {
  description = "Private IP address of Elasticsearch"
  value       = yandex_compute_instance.elasticsearch["elasticsearch-b-1"].network_interface[0].ip_address
}

output "kibana_public_ip" {
  description = "Public IP address of Kibana"
  value       = yandex_compute_instance.kibana["kibana-b-1"].network_interface[0].nat_ip_address
}

output "kibana_private_ip" {
  description = "Private IP address of Kibana"
  value       = yandex_compute_instance.kibana["kibana-b-1"].network_interface[0].ip_address
}

# --- ALB  ---
output "alb_public_ip" {
  description = "Public IP address of Application Load Balancer"
  value       = yandex_alb_load_balancer.web.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}

# --- Summary  ---
output "summary" {
  description = "Quick summary of all public endpoints"
  value = {
    bastion    = yandex_compute_instance.bastion["bastion-a-1"].network_interface[0].nat_ip_address
    grafana    = yandex_compute_instance.grafana["grafana-a-1"].network_interface[0].nat_ip_address
    kibana     = yandex_compute_instance.kibana["kibana-b-1"].network_interface[0].nat_ip_address
    alb        = yandex_alb_load_balancer.web.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
    alb_url    = "http://${yandex_alb_load_balancer.web.listener.0.endpoint.0.address.0.external_ipv4_address.0.address}"
  }
}