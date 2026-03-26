# =============================================================================
# BASTION HOST
# =============================================================================
# Bastion host — единственная ВМ с публичным IP для SSH доступа
# Через неё мы будем подключаться ко всем остальным ВМ в приватных подсетях

resource "yandex_compute_instance" "bastion" {
  name        = "${var.resource_prefix}-bastion"
  description = "Bastion host for SSH access to private instances"
  hostname    = "${var.resource_prefix}-bastion"

  # Зона доступности (используем первую из списка)
  zone = var.availability_zones[0]

  # Платформа и ресурсы
  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  # Загрузочный диск с образом Ubuntu
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-ssd"
      size     = 10
    }
  }

  # Сетевой интерфейс в публичной подсети
  network_interface {
    subnet_id          = yandex_vpc_subnet.public_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion.id]
  }

  # SSH ключ для доступа
  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  # Прерываемая ВМ
  scheduling_policy {
    preemptible = true
  }

  # Разрешаем остановку для обновления параметров
  allow_stopping_for_update = true
}