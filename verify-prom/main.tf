variable "real_certificate" {
  description = "Issue a real TLS certificate (yes/no)"
}

provider "aws" {
  region = "eu-west-1" # "${var.aws_region}"
}

terraform {
  required_version = "= 0.11.7"
}

module "prometheus" {
  source = "modules/prometheus"

  ami_id             = "ami-0d137679f8243e9f8"
  lets_encrypt_email = "reliability-engineering-tools-team@digital.cabinet-office.gov.uk"
  real_certificate   = "${var.real_certificate}"
  volume_to_attach   = "${aws_ebs_volume.promethues-disk.id}"
  domain_name        = "metrics.gds-reliability.engineering"
  prom_priv_ip       = "${var.prometheus_private_ip}"
  logstash_endpoint  = "47c3212e-794a-4be1-af7c-2eac93519b0a-ls.logit.io"
  logstash_port      = 18210
}

resource "aws_ebs_volume" "promethues-disk" {
  availability_zone = "eu-west-1a"
  size              = "20"

  tags {
    Name = "promethues-disk"
  }
}
