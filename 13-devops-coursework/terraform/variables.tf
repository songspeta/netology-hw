variable "yc_token_path" {
  description = "Path to Yandex Cloud service account key file"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-b"]
}

variable "resource_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "devops-coursework"
}

variable "ssh_public_key" {
  description = "Public SSH key for VM access"
  type        = string
}

variable "admin_ip" {
  description = "Your public IP for SSH access"
  type        = string
}

variable "image_family" {
  description = "OS image family for VMs"
  type        = string
  default     = "ubuntu-2404-lts"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "web_servers" {
  description = "Configuration for web servers"
  type = map(object({
    zone   = string
    subnet = string
  }))
  default = {
    web-a-1 = {
      zone   = "ru-central1-a"
      subnet = "private_a"
    }
    web-b-1 = {
      zone   = "ru-central1-b"
      subnet = "private_b"
    }
  }
}

variable "bastion" {
  type = map(object({
    zone   = string
    subnet = string
  }))
  default = {
    bastion-a-1 = {
      zone   = "ru-central1-a"
      subnet = "public_a"
    }
  }
}

variable "elasticsearch" {
  description = "Configuration for Elasticsearch servers"
  type = map(object({
    zone   = string
    subnet = string
  }))
  default = {
    elasticsearch-b-1 = {
      zone   = "ru-central1-b"
      subnet = "private_b"
    }
  }
}

variable "kibana" {
  description = "Configuration for Kibana servers"
  type = map(object({
    zone   = string
    subnet = string
  }))
  default = {
    kibana-b-1 = {
      zone   = "ru-central1-b"
      subnet = "public_b"
    }
  }
}

variable "prometheus" {
  description = "Configuration for Prometheus servers"
  type = map(object({
    zone   = string
    subnet = string
  }))
  default = {
    prometheus-a-1 = {
      zone   = "ru-central1-a"
      subnet = "private_a"
    }
  }
}

variable "grafana" {
  description = "Configuration for Grafana servers"
  type = map(object({
    zone   = string
    subnet = string
  }))
  default = {
    grafana-a-1 = {
      zone   = "ru-central1-a"
      subnet = "public_a"
    }
  }
}