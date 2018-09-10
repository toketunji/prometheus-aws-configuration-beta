module "Prometheus" {
  source = "../../../prometheus"

  ami_id     = "ami-e4ad5983"
  target_vpc = "${aws}"
  enable_ssh = true

  product     = "prom-app"
  environment = "prom-dev-test"

  subnet_ids          = "${module.vpc.public_subnets}"
  availability_zones  = "${data.aws_availability_zones.available.names}"
  vpc_security_groups = ["${aws_security_group.permit_internet_access.id}"]
}

resource "aws_security_group" "permit_internet_access" {
  vpc_id = "${module.vpc.vpc_id}"

  egress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 9090
    to_port   = 9090

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name = "Internet access & prometheus access from GDS in dev env"
  }
}
