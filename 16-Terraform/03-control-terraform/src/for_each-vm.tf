# Переменная для БД
variable "each_vm" {
  type = list(object({
    vm_name     = string
    cpu         = number
    ram         = number
    core_fraction = number
    disk_volume = number
  }))
  default = [
    { vm_name = "main", cpu = 2, ram = 2, core_fraction = 20, disk_volume = 10 },
    { vm_name = "replica", cpu = 2, ram = 4, core_fraction = 20, disk_volume = 20 }
  ]
}

resource "yandex_compute_instance" "db" {
  for_each = { for vm in var.each_vm : vm.vm_name => vm }

  name        = each.value.vm_name
  platform_id = "standard-v3"

  resources {
    cores  = each.value.cpu
    memory = each.value.ram
    core_fraction = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = each.value.disk_volume
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    security_group_ids = [yandex_vpc_security_group.example.id]
  }

  scheduling_policy {
    preemptible = true
  }


  metadata = {
    ssh-keys = "ubuntu:${local.vms_ssh_root_key}"
  }

  depends_on = [yandex_compute_instance.web]
}