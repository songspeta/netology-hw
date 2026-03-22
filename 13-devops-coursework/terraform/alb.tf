# =============================================================================
# APPLICATION LOAD BALANCER (ALB)
# =============================================================================

# --- 1. Target Group (автоматически все web серверы) ---
resource "yandex_alb_target_group" "web" {
  name      = "${var.resource_prefix}-web-tg"
  folder_id = var.folder_id

  # Автоматически добавляем все веб-серверы из коллекции
  dynamic "target" {
    for_each = yandex_compute_instance.web
    content {
      subnet_id  = target.value.network_interface.0.subnet_id
      ip_address = target.value.network_interface.0.ip_address
    }
  }
}

# --- 2. Backend Group ---
resource "yandex_alb_backend_group" "web" {
  name      = "${var.resource_prefix}-web-bg"
  folder_id = var.folder_id

  http_backend {
    name             = "nginx-backend"
    port             = 80
    weight           = 100
    target_group_ids = [yandex_alb_target_group.web.id]

    healthcheck {
      timeout             = "2s"
      interval            = "5s"
      unhealthy_threshold = 2
      healthy_threshold   = 2
      
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# --- 3. HTTP Router ---
resource "yandex_alb_http_router" "web" {
  name      = "${var.resource_prefix}-web-router"
  folder_id = var.folder_id
}

# --- 4. Virtual Host ---
resource "yandex_alb_virtual_host" "web" {
  name           = "${var.resource_prefix}-web-vhost"
  http_router_id = yandex_alb_http_router.web.id

  route {
    name = "web-route"
    
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
      }
    }
  }
}

# --- 5. Load Balancer ---
resource "yandex_alb_load_balancer" "web" {
  name       = "${var.resource_prefix}-alb"
  folder_id  = var.folder_id
  network_id = yandex_vpc_network.main.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public_a.id
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.public_b.id
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
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
}