resource "yandex_lb_target_group" "web" {
  name      = "${var.flow}-target-group"
  region_id = "ru-central1"

  dynamic "target" {
    for_each = yandex_compute_instance.vms
    content {
      subnet_id = yandex_vpc_subnet.main.id
      address   = target.value.network_interface[0].ip_address
    }
  }

  labels = {
    environment = var.flow
    managed-by  = "terraform"
  }
}

resource "yandex_lb_network_load_balancer" "web" {
  name      = "${var.flow}-lb"
  region_id = "ru-central1"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web.id

    healthcheck {
      name = "${var.flow}-healthcheck"
      http_options {
        port = 80
        path = "/"
      }
      timeout             = 10
      interval            = 11
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
  }

  labels = {
    environment = var.flow
    managed-by  = "terraform"
  }
}