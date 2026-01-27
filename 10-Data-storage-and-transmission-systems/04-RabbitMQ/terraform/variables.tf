variable "count_vms" {
  type    = number
  default = 3
}

variable "flow" {
  type    = string
  default = "spet"
}

variable "cloud_id" {
  type = string
  default = "b1g2vjrss298io4rlbvg"
}
variable "folder_id" {
  type = string
  default = "b1gkghqdgd7tqvteo1cf"
}
variable "zone" {
  description = "Зона для размещения ВМ"
  type        = string
  default     = "ru-central1-a"
}

variable "subnet_cidr" {
  description = "CIDR блоки для подсетb"
  type        = string
  default     = "192.168.10.0/24"
}