provider "aws" {
  region = "eu-west-1" # "${var.aws_region}"
}

terraform {
  required_version = "= 0.11.7"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "prometheus-vpc"
  cidr = "10.0.0.0/16"

  # subnets assumes 3 AZs although 3AZs are not implemented elsewhere
  azs              = "${var.az_zone}"
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_dhcp_options      = true
}



module "prometheus" {
  source = "../terraform/modules/prometheus"

  ami_id             = "ami-0d137679f8243e9f8"
  vpc_identification = "${module.vpc.vpc_id}"
  public_vpc_subnets = "${module.vpc.public_subnets}"
  prom_priv_ip       = "${var.prometheus_private_ip}"
}


