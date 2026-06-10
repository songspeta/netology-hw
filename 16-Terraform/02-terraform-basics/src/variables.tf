###cloud vars

variable "yc_token_path" {
  type        = string
  description = "Path to service account key file"
}


variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}


###ssh vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "<your_ssh_ed25519_key>"
  description = "ssh-keygen -t ed25519"
  sensitive   = true
}


### VM Web Variables

variable "vm_web_name" {
  type        = string
  description = "Name of the web VM"
  default     = "platform-web"
}

variable "vm_web_platform_id" {
  type        = string
  description = "Platform ID for the web VM"
  default     = "standard-v3"
}

# variable "vm_web_cores" {
#   type        = number
#   description = "Number of CPU cores for the web VM"
#   default     = 2
# }

# variable "vm_web_memory" {
#   type        = number
#   description = "Amount of RAM for the web VM (in GB)"
#   default     = 2
# }

# variable "vm_web_core_fraction" {
#   type        = number
#   description = "Core fraction for the web VM"
#   default     = 20
# }

variable "vm_web_image_family" {
  type        = string
  description = "Image family for the web VM"
  default     = "ubuntu-2004-lts"
}

### VM DB Variables

variable "vm_db_name" {
  type        = string
  description = "Name of the DB VM"
  default     = "platform-db"
}

variable "vm_db_platform_id" {
  type        = string
  description = "Platform ID for the DB VM"
  default     = "standard-v3"
}

# variable "vm_db_cores" {
#   type        = number
#   description = "Number of CPU cores for the DB VM"
#   default     = 2
# }

# variable "vm_db_memory" {
#   type        = number
#   description = "Amount of RAM for the DB VM (in GB)"
#   default     = 2
# }

# variable "vm_db_core_fraction" {
#   type        = number
#   description = "Core fraction for the DB VM"
#   default     = 20
# }

variable "vm_db_zone" {
  type        = string
  description = "Zone for the DB VM"
  default     = "ru-central1-b"
}

variable "vm_db_cidr" {
  type        = list(string)
  description = "CIDR for the DB subnet"
  default     = ["10.0.2.0/24"]
}


### VMS Resources Map

variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
  }))
  description = "Resources configuration for VMs"

  default = {
    web = {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
    db = {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}

### Metadata Map

variable "metadata" {
  type = map(string)
  description = "Metadata for all VMs"

  default = {
    "serial-port-enable" = "1"
  }
}
