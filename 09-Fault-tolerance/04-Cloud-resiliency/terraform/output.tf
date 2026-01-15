output "lb_ip" {
  value = flatten(yandex_lb_network_load_balancer.web.listener[*].external_address_spec[*].address)[0]
}