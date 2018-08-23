# See https://sites.google.com/a/digital.cabinet-office.gov.uk/gds-internal-it/news/aviationhouse-sourceipaddresses for details.
variable "cidr_admin_whitelist" {
  description = "CIDR ranges permitted to communicate with administrative endpoints"
  type        = "list"

  default = [
    "213.86.153.212/32",
    "213.86.153.213/32",
    "213.86.153.214/32",
    "213.86.153.235/32",
    "213.86.153.236/32",
    "213.86.153.237/32",
    "85.133.67.244/32",
  ]
}

variable "prom_priv_ip" {}

variable "ami_id" {}

variable "prometheus_version" {
  description = "Prometheus version to install in the machine"
  default     = "2.2.1"
}

variable "blackbox_version" {
  description = "Prometheus version to install in the machine"
  default     = "0.12.0"
}

variable "device_mount_path" {
  description = "The path to mount the promethus disk"
  default     = "/dev/sdh"
}

variable "availability_zones" {
  description = "A map of availability zones to subnets"

  type    = "map"
  default = {}
}


variable "instance_size" {
  type = "string"
  description = "This is the default instance size"
  default = "t2.medium"
}

variable "target_vpc" {
  description = "The VPC in which the system will be deployed"
}

variable "public_vpc_subnets" {
  type = "list"
  description = "Public VPC subnets"
}
