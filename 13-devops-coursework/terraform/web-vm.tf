resource "yandex_compute_instance" "web" {
  for_each = var.web_servers

  # Имя ВМ = префикс + ключ из map
  name        = "${var.resource_prefix}-${each.key}"
  hostname    = "${var.resource_prefix}-${each.key}"
  description = "Web server ${each.key}"

  # Зона из значения map
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

  # Подсеть из значения map
  network_interface {
    subnet_id = each.value.subnet == "private_a" ? yandex_vpc_subnet.private_a.id : yandex_vpc_subnet.private_b.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.web.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }

  allow_stopping_for_update = true
}