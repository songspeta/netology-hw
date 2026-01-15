# Получаем образ Ubuntu 22.04 LTS
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}
# Получаем образ gitlab
data "yandex_compute_image" "gitlab" {
  family = "gitlab"
}

# ВМ для gitlab
resource "yandex_compute_instance" "gitlab" {
  name        = "gitlab"
  hostname    = "gitlab"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 4
    memory        = 8
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.gitlab.image_id
      type     = "network-hdd"
      size     = 30
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg.id]
  }

  metadata = {
    user-data = file("./cloud-init.yml")
  }

  scheduling_policy {
    preemptible = true
  }
}

# ВМ для runner
resource "yandex_compute_instance" "runner" {
  name        = "runner"
  hostname    = "runner"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.image_id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg.id]
  }

  metadata = {
    user-data = file("./cloud-init.yml")
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "local_file" "inventory" {
  content  = <<-XYZ
[yc:children]
gitlab
runner

[yc:vars]
ansible_user=spet
ansible_ssh_private_key_file = ~/.ssh/id_rsa

[gitlab]
${yandex_compute_instance.gitlab.network_interface.0.nat_ip_address}
[runner]
${yandex_compute_instance.runner.network_interface.0.nat_ip_address}
  XYZ
  filename = "${path.module}/../ansible/hosts.ini"
}