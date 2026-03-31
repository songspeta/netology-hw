# =============================================================================
# SSH Config Generation
# =============================================================================

resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/templates/ssh_config.tftpl", {
    bastion_ip = yandex_compute_instance.bastion["bastion-a-1"].network_interface[0].nat_ip_address
    web_a_ip   = yandex_compute_instance.web["web-a-1"].network_interface[0].ip_address
    web_b_ip   = yandex_compute_instance.web["web-b-1"].network_interface[0].ip_address
    elasticsearch_ip = yandex_compute_instance.elasticsearch["elasticsearch-b-1"].network_interface[0].ip_address
    kibana_ip = yandex_compute_instance.kibana["kibana-b-1"].network_interface[0].ip_address
    prometheus_ip = yandex_compute_instance.prometheus["prometheus-a-1"].network_interface[0].ip_address
    grafana_ip = yandex_compute_instance.grafana["grafana-a-1"].network_interface[0].ip_address
  })

  filename = "/home/spet/netology-hw/13-devops-coursework/ssh_conf/devops-coursework.conf"

  provisioner "local-exec" {
    command = "chmod 600 ${self.filename}"
  }
}

resource "null_resource" "cleanup_ssh_config" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f /home/spet/netology-hw/13-devops-coursework/ssh_conf/devops-coursework.conf"
  }

  depends_on = [local_file.ssh_config]
}