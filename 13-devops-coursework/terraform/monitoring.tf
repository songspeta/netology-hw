# =============================================================================
# MONITORING (PROMETHEUS + GRAFANA)
# =============================================================================
# Prometheus — сбор метрик (приватная подсеть, нет публичного IP)
# Grafana — визуализация метрик (публичная подсеть, есть публичный IP)

resource "yandex_compute_instance" "prometheus" {
  for_each = var.prometheus

  name        = "${var.resource_prefix}-${each.key}"
  hostname    = "${var.resource_prefix}-${each.key}"
  description = "Prometheus server ${each.key}"

  zone        = each.value.zone
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
      size     = 20
    }
  }

  network_interface {
    subnet_id          = each.value.subnet == "private_a" ? yandex_vpc_subnet.private_a.id : yandex_vpc_subnet.private_b.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.monitoring.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }

  allow_stopping_for_update = true
}

# --- Grafana Server ---
resource "yandex_compute_instance" "grafana" {
  for_each = var.grafana

  name        = "${var.resource_prefix}-${each.key}"
  hostname    = "${var.resource_prefix}-${each.key}"
  description = "Grafana server ${each.key}"

  zone        = each.value.zone
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
    subnet_id          = each.value.subnet == "public_a" ? yandex_vpc_subnet.public_a.id : yandex_vpc_subnet.public_b.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.monitoring.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }

  allow_stopping_for_update = true
}