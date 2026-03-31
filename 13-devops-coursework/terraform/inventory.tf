# =============================================================================
# ANSIBLE INVENTORY (DYNAMIC)
# =============================================================================

data "template_file" "ansible_inventory" {
  template = file("${path.module}/templates/inventory.tmpl")

  vars = {
    bastion_public_ip  = yandex_compute_instance.bastion["bastion-a-1"].network_interface[0].nat_ip_address
    bastion_private_ip = yandex_compute_instance.bastion["bastion-a-1"].network_interface[0].ip_address

    web_a_private_ip = yandex_compute_instance.web["web-a-1"].network_interface[0].ip_address
    web_a_zone       = yandex_compute_instance.web["web-a-1"].zone
    web_b_private_ip = yandex_compute_instance.web["web-b-1"].network_interface[0].ip_address
    web_b_zone       = yandex_compute_instance.web["web-b-1"].zone

    prometheus_private_ip = yandex_compute_instance.prometheus["prometheus-a-1"].network_interface[0].ip_address
    grafana_private_ip    = yandex_compute_instance.grafana["grafana-a-1"].network_interface[0].ip_address
    grafana_public_ip     = yandex_compute_instance.grafana["grafana-a-1"].network_interface[0].nat_ip_address

    elasticsearch_private_ip = yandex_compute_instance.elasticsearch["elasticsearch-b-1"].network_interface[0].ip_address
    kibana_private_ip        = yandex_compute_instance.kibana["kibana-b-1"].network_interface[0].ip_address
    kibana_public_ip         = yandex_compute_instance.kibana["kibana-b-1"].network_interface[0].nat_ip_address

    alb_public_ip = yandex_alb_load_balancer.web.listener.0.endpoint.0.address.0.external_ipv4_address.0.address


    ssh_user = "ubuntu"
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/hosts.ini"
  content  = data.template_file.ansible_inventory.rendered

  lifecycle {
    ignore_changes = [content]
  }
}