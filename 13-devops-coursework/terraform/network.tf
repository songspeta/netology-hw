# =============================================================================
# NETWORK (VPC, SUBNETS, NAT GATEWAY, ROUTE TABLES)
# =============================================================================
# Создаём облачную сеть
resource "yandex_vpc_network" "main" {
  name        = "${var.resource_prefix}-network"
  description = "Main network for DevOps coursework"
}

# =============================================================================
# PUBLIC SUBNETS (Bastion, ALB, Grafana, Kibana)
# =============================================================================
# Публичная подсеть Zone A
resource "yandex_vpc_subnet" "public_a" {
  name           = "${var.resource_prefix}-public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.1.0/24"]
}

# Публичная подсеть Zone B
resource "yandex_vpc_subnet" "public_b" {
  name           = "${var.resource_prefix}-public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

# =============================================================================
# PRIVATE SUBNETS (Web, Prometheus, Elasticsearch)
# =============================================================================
# Приватная подсеть Zone A
resource "yandex_vpc_subnet" "private_a" {
  name           = "${var.resource_prefix}-private-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.10.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

# Приватная подсеть Zone B
resource "yandex_vpc_subnet" "private_b" {
  name           = "${var.resource_prefix}-private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.11.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

# =============================================================================
# NAT GATEWAY (для выхода в интернет из приватных подсетей)
# =============================================================================
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "${var.resource_prefix}-nat-gateway"

  shared_egress_gateway {}
}

# =============================================================================
# ROUTE TABLES
# =============================================================================
# Таблица маршрутизации для приватных подсетей (с NAT)
resource "yandex_vpc_route_table" "private" {
  name       = "${var.resource_prefix}-private-rt"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Таблица маршрутизации для публичных подсетей (без NAT, прямой интернет)
resource "yandex_vpc_route_table" "public" {
  name       = "${var.resource_prefix}-public-rt"
  network_id = yandex_vpc_network.main.id
}