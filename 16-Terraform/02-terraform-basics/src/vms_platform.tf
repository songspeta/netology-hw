data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_image_family
}

# Вторая подсеть для зоны ru-central1-b
resource "yandex_vpc_subnet" "develop_db" {
  name           = "${var.vpc_name}-db"
  zone           = var.vm_db_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.vm_db_cidr
}

# ВМ для базы данных
resource "yandex_compute_instance" "db" {
  name        = local.vm_db_full_name
  platform_id = var.vm_db_platform_id
  zone        = var.vm_db_zone

  resources {
    cores         = var.vms_resources["db"].cores
    memory        = var.vms_resources["db"].memory
    core_fraction = var.vms_resources["db"].core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop_db.id
    nat       = true
  }

metadata = merge(var.metadata, {
  "ssh-keys" = "ubuntu:${var.vms_ssh_root_key}"
})
}