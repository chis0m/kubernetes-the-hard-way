variable "region" {
  type        = string
  description = "The Region were resources are to be hosted"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "enable_dns_support" {
  type = bool
}

variable "enable_dns_hostnames" {
  type = bool
}

variable "ubuntu_ami" {
  type = string
}

variable "key_name" {
  type = string
}
