variable "prometheus_private_ip" {
  description = "The private ip address for prometheus"
  default     = "10.0.0.155"
}

variable "alertmanager_private_ip" {
  description = "The private ip address for alertmanager"
  default     = "10.0.0.38"
}

variable "az_zone" {
  type  = "list"
  description = "The availability zone in which the disk and instance reside. "
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

