provider "aws" {
  region = "eu-west-1" # "${var.aws_region}"
}

terraform {
  required_version = "= 0.11.7"
}

module "prometheus" {
  source = "../terraform/modules/prometheus"

  ami_id             = "ami-0d137679f8243e9f8"
  domain_name        = "metrics.gds-reliability.engineering"
  prom_priv_ip       = "${var.prometheus_private_ip}"
  logstash_endpoint  = "47c3212e-794a-4be1-af7c-2eac93519b0a-ls.logit.io"
  logstash_port      = 18210
}


