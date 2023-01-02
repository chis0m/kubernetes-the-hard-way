variable "infrastructure_name" {
  type        = string
  description = "The base name of this infrastructure"
}

variable "region" {
  type        = string
  description = "The Region were resources are to be hosted"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "cluster_cidr" {
  type        = string
  description = "K8 cluster CIDR block"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR block"
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
