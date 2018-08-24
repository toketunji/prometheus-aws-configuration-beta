resource "aws_security_group" "ssh_from_gds" {
  vpc_id      = "${var.vpc_identification}"
  name        = "SSH from GDS"
  description = "Allow SSH access from GDS"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.cidr_admin_whitelist}"]
  }

  tags {
    Name = "SSH from GDS"
  }
}

resource "aws_security_group" "http_outbound" {
  vpc_id      = "${var.vpc_identification}"
  name        = "HTTP outbound"
  description = "Allow HTTP connections out to the internet"

  egress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags {
    Name = "HTTP outbound"
  }
}

resource "aws_security_group" "external_http_traffic" {
  vpc_id      = "${var.vpc_identification}"
  name        = "external_http_traffic"
  description = "Allow external http traffic"

  ingress {
    protocol    = "tcp"
    from_port   = 9090
    to_port     = 9090
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 9090
    to_port     = 9090
    self = true
  }

  ingress {
    protocol    = "tcp"
    from_port   = 9100
    to_port     = 9100
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 9100
    to_port     = 9100
    self = true
  }


  tags {
    Name = "external-http-traffic"
  }
}