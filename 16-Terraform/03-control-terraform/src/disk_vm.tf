# 1. Создаем 3 одинаковых диска по 1 Гб через count
resource "yandex_compute_disk" "extra" {
  count = 3

  name     = "extra-disk-${count.index + 1}"
  size     = 1
  type     = "network-ssd"
  zone     = var.default_zone
}

# 2. Создаем одиночную ВМ "storage"
resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = 10
    }
  }

  # Подключаем созданные выше диски через dynamic + for_each
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.extra

    content {
      disk_id = secondary_disk.value.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "ubuntu:${local.vms_ssh_root_key}"
  }
}