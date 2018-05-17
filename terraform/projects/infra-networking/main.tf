module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.stack_name}-vpc"
  cidr = "10.0.0.0/16"

  # subnets assumes 3 AZs although 3AZs are not implemented elsewhere
  azs              = "${data.aws_availability_zones.available.names}"
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  enable_nat_gateway = true

  # no `Name` tag unlike other resources as this is taken care of by the vpc module `name` property
}
