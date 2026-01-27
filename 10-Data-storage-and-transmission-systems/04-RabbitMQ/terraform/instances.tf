data "yandex_compute_image" "ubuntu_2204_lts" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vms" {
  count = var.count_vms

  name        = "${var.flow}-vm-${count.index + 1}"
  hostname    = "${var.flow}-vm-${count.index + 1}"
  platform_id = "standard-v3"
  zone        =  var.zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 50
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_2204_lts.id
      type     = "network-ssd"
      size     = 10
    }
  }
   scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id          = element(yandex_vpc_subnet.main.*.id, count.index)
    security_group_ids = [yandex_vpc_security_group.main.id]
    nat                = true
  }

  metadata = {
   user-data = templatefile("./cloud-init.yml.tftpl", {
      instance_name = "${var.flow}-vm-${count.index + 1}"
    })
    serial-port-enable = 1
  }

  labels = {
    environment = var.flow
    zone        = var.zone
    instance    = count.index + 1
  }

  depends_on = [
    yandex_vpc_subnet.main,
    yandex_vpc_security_group.main
  ]
}