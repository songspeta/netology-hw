# Сеть
resource "yandex_vpc_network" "net" {
  name = "jenkins-nexus-net"
}

# Подсеть
resource "yandex_vpc_subnet" "subnet" {
  name           = "jenkins-nexus-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

# security group
resource "yandex_vpc_security_group" "sg" {
  name       = "jenkins-nexus-sg"
  network_id = yandex_vpc_network.net.id

  # SSH
  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]  # лучше заменить на ваш IP
  }

  # Jenkins
  ingress {
    protocol       = "TCP"
    port           = 8080
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Nexus UI
  ingress {
    protocol       = "TCP"
    port           = 8081
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

   # Nexus Docker registry
  ingress {
    protocol       = "TCP"
    port           = 8082
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}