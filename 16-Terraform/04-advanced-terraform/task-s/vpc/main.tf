resource "yandex_vpc_subnet" "develop" {
  name           = "${var.env_name}-${var.zone}"
  zone           = var.zone
  network_id     = var.network_id
  v4_cidr_blocks = [var.cidr]
}