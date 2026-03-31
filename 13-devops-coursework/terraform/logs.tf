# =============================================================================
# LOGGING (ELASTICSEARCH + KIBANA)
# =============================================================================
# Elasticsearch — хранение и поиск логов (приватная подсеть)
# Kibana — визуализация логов (публичная подсеть)

# --- Elasticsearch Server ---
resource "yandex_compute_instance" "elasticsearch" {
  for_each = var.elasticsearch

  name        = "${var.resource_prefix}-${each.key}"
  hostname    = "${var.resource_prefix}-${each.key}"
  description = "Elasticsearch server ${each.key}"

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
      size     = 30
    }
  }

  network_interface {
    subnet_id          = each.value.subnet == "private_a" ? yandex_vpc_subnet.private_a.id : yandex_vpc_subnet.private_b.id
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

# --- Kibana Server ---
resource "yandex_compute_instance" "kibana" {
  for_each = var.kibana

  name        = "${var.resource_prefix}-${each.key}"
  hostname    = "${var.resource_prefix}-${each.key}"
  description = "Kibana server ${each.key}"

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
      size     = 10
    }
  }

  network_interface {
    subnet_id          = each.value.subnet == "public_a" ? yandex_vpc_subnet.public_a.id : yandex_vpc_subnet.public_b.id
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