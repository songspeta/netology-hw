resource "yandex_vpc_network" "main" {
  name = "${var.flow}-network"

  labels = {
    environment = var.flow
    managed-by  = "terraform"
  }
}

resource "yandex_vpc_subnet" "main" {

  name           = "${var.flow}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.subnet_cidr]
  labels = {
    zone        = var.zone
    environment = var.flow
  }
}

resource "yandex_vpc_security_group" "main" {
  name        = "${var.flow}-sg"
  network_id  = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "SSH access"
  }

    ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "WEB"
  }

  ingress {
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Ping"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "All outgoing traffic"
  }

  labels = {
    environment = var.flow
    managed-by  = "terraform"
  }
}