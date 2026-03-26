# =============================================================================
# SSH Config Generation
# =============================================================================

# Создаём директорию для SSH конфигов в проекте
resource "local_file" "ssh_config" {
  content = templatefile("${path.module}/templates/ssh_config.tftpl", {
    bastion_ip       = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
    web_a_ip         = yandex_compute_instance.web["web-a-1"].network_interface[0].ip_address
    web_b_ip         = yandex_compute_instance.web["web-b-1"].network_interface[0].ip_address
    elasticsearch_ip = yandex_compute_instance.elasticsearch.network_interface[0].ip_address
    kibana_ip        = yandex_compute_instance.kibana.network_interface[0].ip_address
    prometheus_ip    = yandex_compute_instance.prometheus.network_interface[0].ip_address
    grafana_ip       = yandex_compute_instance.grafana.network_interface[0].ip_address
  })

  filename = "/home/spet/netology-hw/13-devops-coursework/ssh_conf/devops-coursework.conf"

  # Устанавливаем правильные права (SSH требует 600)
  provisioner "local-exec" {
    command = "chmod 600 ${self.filename}"
  }
}

# Очистка при destroy
resource "null_resource" "cleanup_ssh_config" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f /home/spet/netology-hw/13-devops-coursework/ssh_conf/devops-coursework.conf"
  }

  depends_on = [local_file.ssh_config]
}