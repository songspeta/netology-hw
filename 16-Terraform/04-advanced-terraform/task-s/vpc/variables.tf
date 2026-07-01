variable "env_name" {
  description = "Environment name"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
}

variable "cidr" {
  description = "CIDR block for subnet"
  type        = string
}

variable "network_id" {
  description = "Network ID (optional - if not provided, will use existing network)"
  type        = string
  default     = null
}