# Получаем образ Ubuntu 22.04 LTS
data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

# ВМ для Jenkins
resource "yandex_compute_instance" "jenkins" {
  name        = "jenkins"
  hostname    = "jenkins"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
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

# ВМ для Nexus
resource "yandex_compute_instance" "nexus" {
  name        = "nexus"
  hostname    = "nexus"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
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
jenkins
nexus

[yc:vars]
ansible_user=spet
ansible_ssh_private_key_file = ~/.ssh/id_rsa

[jenkins]
${yandex_compute_instance.jenkins.network_interface.0.nat_ip_address}
[nexus]
${yandex_compute_instance.nexus.network_interface.0.nat_ip_address}
  XYZ
  filename = "${path.module}/../ansible/hosts.ini"
}