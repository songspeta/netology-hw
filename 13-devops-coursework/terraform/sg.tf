# =============================================================================
# SECURITY GROUPS
# =============================================================================

# --- Bastion Security Group ---
# Доступ ТОЛЬКО с одного IP
resource "yandex_vpc_security_group" "bastion" {
  name        = "${var.resource_prefix}-bastion-sg"
  description = "Security group for Bastion host"
  network_id  = yandex_vpc_network.main.id

  # Входящий: SSH только с одного IP
  ingress {
    description    = "SSH from admin"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [var.admin_ip]
  }

  # Исходящий: любой трафик
  egress {
    description    = "Allow all outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# --- Web Security Group ---
# HTTP от всех (для ALB healthcheck), SSH только от Bastion
resource "yandex_vpc_security_group" "web" {
  name        = "${var.resource_prefix}-web-sg"
  description = "Security group for Web servers"
  network_id  = yandex_vpc_network.main.id

 # Входящий: Node Exporter metrics от Prometheus
  ingress {
    description       = "Node Exporter metrics from Prometheus"
    protocol          = "TCP"
    port              = 9100
    security_group_id = yandex_vpc_security_group.monitoring.id
  }

  # Входящий: Nginx Exporter metrics от Prometheus
  ingress {
    description       = "Nginx Exporter metrics from Prometheus"
    protocol          = "TCP"
    port              = 9113
    security_group_id = yandex_vpc_security_group.monitoring.id
  }

  # Входящий: HTTP от всех (ALB healthcheck + трафик)
  ingress {
    description    = "HTTP from ALB"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Входящий: SSH только от Bastion SG
  ingress {
    description       = "SSH from Bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  # Исходящий: любой трафик
  egress {
    description    = "Allow all outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# --- Monitoring Security Group (Prometheus + Grafana) ---
# Порты экспортеров только внутри группы, SSH от Bastion
resource "yandex_vpc_security_group" "monitoring" {
  name        = "${var.resource_prefix}-monitoring-sg"
  description = "Security group for Monitoring (Prometheus, Grafana)"
  network_id  = yandex_vpc_network.main.id

# Входящий: Prometheus API/UI (порт 9090) — для Grafana datasource + отладки
ingress {
  description       = "Prometheus API from monitoring group"
  protocol          = "TCP"
  port              = 9090
  predefined_target = "self_security_group"  # ← только внутри monitoring SG
}
  # Входящий: Prometheus scrapes (9100-9113) от самой группы
  ingress {
    description       = "Prometheus scrapes"
    protocol          = "TCP"
    from_port         = 9100
    to_port           = 9113
    predefined_target = "self_security_group"
  }

  # Входящий: Grafana UI (порт 3000) от всех (публичный доступ)
  ingress {
    description    = "Grafana UI"
    protocol       = "TCP"
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Входящий: SSH только от Bastion SG
  ingress {
    description       = "SSH from Bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  # Исходящий: любой трафик
  egress {
    description    = "Allow all outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# --- Logging Security Group (Elasticsearch + Kibana) ---
# Elasticsearch только внутри сети, Kibana публичный, SSH от Bastion
resource "yandex_vpc_security_group" "logging" {
  name        = "${var.resource_prefix}-logging-sg"
  description = "Security group for Logging (Elasticsearch, Kibana)"
  network_id  = yandex_vpc_network.main.id

# Входящий: Node Exporter metrics от Prometheus
  ingress {
    description       = "Node Exporter metrics from Prometheus"
    protocol          = "TCP"
    port              = 9100
    security_group_id = yandex_vpc_security_group.monitoring.id
  }


  # Входящий: Elasticsearch (9200-9300) от Web и Monitoring SG

    ingress {
    description       = "Elasticsearch from Logging group (Kibana)"
    protocol          = "TCP"
    from_port         = 9200
    to_port           = 9300
    predefined_target = "self_security_group"
  }
  ingress {
    description       = "Elasticsearch from Web"
    protocol          = "TCP"
    from_port         = 9200
    to_port           = 9300
    security_group_id = yandex_vpc_security_group.web.id
  }

  ingress {
    description       = "Elasticsearch from Monitoring"
    protocol          = "TCP"
    from_port         = 9200
    to_port           = 9300
    security_group_id = yandex_vpc_security_group.monitoring.id
  }

  # Входящий: Kibana UI (5601) от всех (публичный доступ)
  ingress {
    description    = "Kibana UI"
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Входящий: SSH только от Bastion SG
  ingress {
    description       = "SSH from Bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  # Исходящий: любой трафик
  egress {
    description    = "Allow all outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

# --- ALB Security Group ---
# HTTP/HTTPS от всех, исходящий на веб-сервера
resource "yandex_vpc_security_group" "alb" {
  name        = "${var.resource_prefix}-alb-sg"
  description = "Security group for Application Load Balancer"
  network_id  = yandex_vpc_network.main.id

  # Входящий: HTTP от всех
  ingress {
    description    = "HTTP from internet"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Входящий: HTTPS от всех
  ingress {
    description    = "HTTPS from internet"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Исходящий: HTTP к веб-серверам
  egress {
    description       = "HTTP to Web servers"
    protocol          = "TCP"
    port              = 80
    security_group_id = yandex_vpc_security_group.web.id
  }

  # Исходящий: любой другой трафик
  egress {
    description    = "Allow all other outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}