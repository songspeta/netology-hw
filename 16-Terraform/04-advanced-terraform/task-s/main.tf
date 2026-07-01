# Создаем сеть отдельно
resource "yandex_vpc_network" "develop" {
  name = "develop"
}

# Модуль VPC для зоны A
module "vpc_dev_a" {
  source     = "./vpc"
  env_name   = "develop"
  zone       = "ru-central1-a"
  cidr       = "10.0.1.0/24"
  network_id = yandex_vpc_network.develop.id
}

# Модуль VPC для зоны B
module "vpc_dev_b" {
  source     = "./vpc"
  env_name   = "develop"
  zone       = "ru-central1-b"
  cidr       = "10.0.2.0/24"
  network_id = yandex_vpc_network.develop.id
}

# Модуль для маркетинговых ВМ (зона A)
module "marketing_vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"

  env_name       = "marketing"
  network_id     = module.vpc_dev_a.network_id
  subnet_zones   = ["ru-central1-a"]
  subnet_ids     = [module.vpc_dev_a.subnet_id]
  instance_name  = "marketing-web"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    owner   = "d.spetnicky"
    project = "marketing"
  }

  metadata = {
    user-data             = data.template_file.cloudinit_marketing.rendered
    serial-port-enable    = 1
  }
}

# Модуль для аналитических ВМ (зона B)
module "analytics_vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=main"

  env_name       = "analytics"
  network_id     = module.vpc_dev_b.network_id
  subnet_zones   = ["ru-central1-b"]
  subnet_ids     = [module.vpc_dev_b.subnet_id]
  instance_name  = "analytics-web"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true

  labels = {
    owner   = "d.spetnicky"
    project = "analytics"
  }

  metadata = {
    user-data             = data.template_file.cloudinit_analytics.rendered
    serial-port-enable    = 1
  }
}

# Шаблон cloud-init для marketing
data "template_file" "cloudinit_marketing" {
  template = file("./cloud-init.yml")

  vars = {
    ssh_key = var.public_key
  }
}

# Шаблон cloud-init для analytics
data "template_file" "cloudinit_analytics" {
  template = file("./cloud-init.yml")

  vars = {
    ssh_key = var.public_key
  }
}