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

variable "az_zone" {
  type  = "list"
  description = "The availability zone in which the disk and instance reside. "
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}


variable "instance_size" {
  type = "string"
  description = "This is the default instance size"
  default = "t2.medium"
}

variable "vpc_identification" {
  type = "string"
  description = "The VPc in which the system should be deployed"
  default = "vpc-7a17b81d"
}

variable "ssh_key_name" {
  type = "string"
  description = "This is the default instance EC2 access key"
  default = "djeche-insecure"
}


variable "public_vpc_subnets" {
  type = "list"
  description = "Public VPC subnets"
}