# =============================================================================
# ANSIBLE INVENTORY (DYNAMIC)
# =============================================================================
# Генерирует hosts.ini для Ansible с актуальными IP-адресами всех ВМ

data "template_file" "ansible_inventory" {
  template = file("${path.module}/templates/inventory.tmpl")
  
  vars = {
    # Bastion
    bastion_public_ip  = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
    bastion_private_ip = yandex_compute_instance.bastion.network_interface.0.ip_address
    
    # Web Servers
    web_a_private_ip = yandex_compute_instance.web["web-a-1"].network_interface.0.ip_address
    web_b_private_ip = yandex_compute_instance.web["web-b-1"].network_interface.0.ip_address
    
    # Monitoring
    prometheus_private_ip = yandex_compute_instance.prometheus.network_interface.0.ip_address
    grafana_public_ip     = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
    grafana_private_ip    = yandex_compute_instance.grafana.network_interface.0.ip_address
    
    # Logging
    elasticsearch_private_ip = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
    kibana_public_ip         = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
    kibana_private_ip        = yandex_compute_instance.kibana.network_interface.0.ip_address
    
    # ALB
    alb_public_ip = yandex_alb_load_balancer.web.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
    
    # SSH Settings
    ssh_user = "ubuntu"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/hosts.ini"
  content  = data.template_file.ansible_inventory.rendered
  
  # Не перезаписывать при изменениях (чтобы Ansible не ломался)
  lifecycle {
    ignore_changes = [content]
  }
}