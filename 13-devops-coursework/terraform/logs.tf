# =============================================================================
# LOGGING (ELASTICSEARCH + KIBANA)
# =============================================================================
# Elasticsearch — хранение и поиск логов (приватная подсеть, зона B)
# Kibana — визуализация логов (публичная подсеть, зона B)

# --- Elasticsearch Server (Zone B) ---
resource "yandex_compute_instance" "elasticsearch" {
  name        = "${var.resource_prefix}-elasticsearch"
  description = "Elasticsearch logging server (zone B)"
  hostname    = "${var.resource_prefix}-elasticsearch"

  zone        = "ru-central1-b"
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
      size     = 30
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_b.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.logging.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }

  allow_stopping_for_update = true
}

# --- Kibana Server (Zone B) ---
resource "yandex_compute_instance" "kibana" {
  name        = "${var.resource_prefix}-kibana"
  description = "Kibana visualization server (zone B)"
  hostname    = "${var.resource_prefix}-kibana"

  zone        = "ru-central1-b"
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
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_b.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.logging.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }

  allow_stopping_for_update = true
}