# Целевая группа
resource "yandex_alb_target_group" "web_tg" {
  name = "web-tg-${var.flow}"

  target {
    subnet_id  = yandex_vpc_subnet.develop_a.id
    ip_address = yandex_compute_instance.web_a.network_interface[0].ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.develop_b.id
    ip_address = yandex_compute_instance.web_b.network_interface[0].ip_address
  }
}

# Группа бэкендов
resource "yandex_alb_backend_group" "web_bg" {
  name = "web-bg-${var.flow}"

  http_backend {
    name             = "web-backend"
    port             = 80
    target_group_ids = [yandex_alb_target_group.web_tg.id]

    healthcheck {
      timeout  = "1s"
      interval = "2s"
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# HTTP-роутер
resource "yandex_alb_http_router" "web_router" {
  name = "web-router-${var.flow}"
}

# Виртуальный хост
resource "yandex_alb_virtual_host" "default" {
  name           = "default-vhost-${var.flow}"
  http_router_id = yandex_alb_http_router.web_router.id

  route {
    name = "default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_bg.id
      }
    }
  }
}

# Application Load Balancer
resource "yandex_alb_load_balancer" "web_lb" {
  name        = "web-lb-${var.flow}"
  network_id  = yandex_vpc_network.develop.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.develop_a.id
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.develop_b.id
    }
  }

  listener {
    name = "http-listener"
    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web_router.id
      }
    }
  }
}