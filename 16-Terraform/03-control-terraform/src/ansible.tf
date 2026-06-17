# Собираем данные о веб-машинах
locals {
  web_hosts = [
    for i in range(2) : {
      name = "web-${i + 1}"
      ip   = yandex_compute_instance.web[i].network_interface[0].ip_address
      fqdn = yandex_compute_instance.web[i].fqdn
    }
  ]

  # Собираем данные о БД
  db_hosts = [
    for vm in var.each_vm : {
      name = vm.vm_name
      ip   = yandex_compute_instance.db[vm.vm_name].network_interface[0].ip_address
      fqdn = yandex_compute_instance.db[vm.vm_name].fqdn
    }
  ]

  # Собираем данные о storage
  storage_hosts = [
    {
      name = "storage"
      ip   = yandex_compute_instance.storage.network_interface[0].ip_address
      fqdn = yandex_compute_instance.storage.fqdn
    }
  ]
}

# Генерируем inventory-файл из шаблона
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    web_hosts     = local.web_hosts
    db_hosts      = local.db_hosts
    storage_hosts = local.storage_hosts
  })

  filename = "${path.module}/inventory.ini"
}