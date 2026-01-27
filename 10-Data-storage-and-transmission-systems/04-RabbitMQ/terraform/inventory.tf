resource "local_file" "inventory" {
  content = <<XYZ
[yc:children]
vm

[yc:vars]
ansible_user=spet
ansible_ssh_private_key_file = ~/.ssh/id_rsa

[vm]
${join("\n", formatlist("%s ansible_host=%s",
  [for i in range(var.count_vms) : "vm${i + 1}"],
  [for instance in yandex_compute_instance.vms : instance.network_interface[0].nat_ip_address]
))}

XYZ
  filename = "${path.module}/../ansible/hosts.ini"
}