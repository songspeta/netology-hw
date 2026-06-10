output "web_vm_info" {
  description = "Information about web VM"
  value = {
    name         = yandex_compute_instance.platform.name
    external_ip  = yandex_compute_instance.platform.network_interface[0].nat_ip_address
    internal_ip  = yandex_compute_instance.platform.network_interface[0].ip_address
    fqdn         = yandex_compute_instance.platform.fqdn
  }
}

output "db_vm_info" {
  description = "Information about DB VM"
  value = {
    name         = yandex_compute_instance.db.name
    external_ip  = yandex_compute_instance.db.network_interface[0].nat_ip_address
    internal_ip  = yandex_compute_instance.db.network_interface[0].ip_address
    fqdn         = yandex_compute_instance.db.fqdn
  }
}