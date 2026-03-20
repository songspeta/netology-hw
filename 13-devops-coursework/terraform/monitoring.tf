# =============================================================================
# MONITORING (PROMETHEUS + GRAFANA)
# =============================================================================
# Prometheus — сбор метрик (приватная подсеть, нет публичного IP)
# Grafana — визуализация метрик (публичная подсеть, есть публичный IP)

# --- Prometheus Server ---
resource "yandex_compute_instance" "prometheus" {
  name        = "${var.resource_prefix}-prometheus"
  description = "Prometheus monitoring server"
  hostname    = "${var.resource_prefix}-prometheus"

  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-ssd"
      size     = 20  # Больше диск для хранения метрик
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_a.id
    nat                = false  # ❌ Нет публичного IP (приватная подсеть)
    security_group_ids = [yandex_vpc_security_group.monitoring.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true  # ✅ Прерываемая ВМ (экономия)
  }

  allow_stopping_for_update = true
}

# --- Grafana Server ---
resource "yandex_compute_instance" "grafana" {
  name        = "${var.resource_prefix}-grafana"
  description = "Grafana visualization server"
  hostname    = "${var.resource_prefix}-grafana"

  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-ssd"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_a.id
    nat                = true  # ✅ Есть публичный IP (публичная подсеть)
    security_group_ids = [yandex_vpc_security_group.monitoring.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true  # ✅ Прерываемая ВМ (экономия)
  }

  allow_stopping_for_update = true
}