output "vm_public_ips" {
  value = {
    for idx, instance in yandex_compute_instance.vms :
    "vm${idx + 1}" => instance.network_interface[0].nat_ip_address
  }
}