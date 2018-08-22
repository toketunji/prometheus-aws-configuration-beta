terraform {
  required_version = ">= 0.11.2"
}

#Instance profile


resource "aws_iam_instance_profile" "prometheus_instance_profile" {
  name = "prometheus_config_reader_profile"
  role = "${aws_iam_role.prometheus_role.name}"
}

resource "aws_iam_role" "prometheus_role" {
  name = "prometheus_profile"

  assume_role_policy = "${data.aws_iam_policy_document.prometheus_assume_role_policy.json}"
}

data "aws_iam_policy_document" "prometheus_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_role_policy" "prometheus_extended_policy" {
  name  = "Prometheus_instance_profile"
  policy = "${data.aws_iam_policy_document.instance_role_policy.json}"
  role = "${aws_iam_role.prometheus_role.id}"
}

##

data "aws_iam_policy_document" "instance_role_policy" {

  statement {
    sid = "ec2Policy"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    sid = "s3Bucket"
    actions = [
      "s3:Get*",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.prometheus_config.id}/*",
      "arn:aws:s3:::${aws_s3_bucket.prometheus_config.id}",
    ]

  }
}

data "template_file" "prometheus_config_template" {
  template = "${file("${path.module}/prometheus.conf.tpl")}"

  vars {
    prometheus_ips = "${join("\",\"", formatlist("%s:9090\",\"%s:9100", aws_instance.prometheus.*.private_ip, aws_instance.prometheus.*.private_ip))}"
    ec2_instance_profile = "${aws_iam_instance_profile.prometheus_instance_profile.name}"
  }
}

resource "aws_s3_bucket_object" "prometheus_config" {
  bucket  = "${aws_s3_bucket.prometheus_config.id}"
  key     = "prometheus/prometheus.yml"
  content = "${data.template_file.prometheus_config_template.rendered}"
  etag    = "${md5(data.template_file.prometheus_config_template.rendered)}"
}



resource "aws_instance" "prometheus" {
  count = "${length(var.az_zone)}"


  ami                  = "${var.ami_id}"
  instance_type        = "${var.instance_size}"
  user_data            = "${data.template_file.user_data_script.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.prometheus_instance_profile.id}"
  subnet_id            = "${element(var.public_vpc_subnets, count.index)}"
  availability_zone    = "${element(var.az_zone, count.index)}"
  key_name             = "${var.ssh_key_name}"

  vpc_security_group_ids = [
      "${aws_security_group.ssh_from_gds.id}",
      "${aws_security_group.http_outbound.id}",
      "${aws_security_group.external_http_traffic.id}",
    ]

  tags {
    Name = "Prometheus"
  }
}

resource "aws_volume_attachment" "attach-prometheus-disk" {
  count = "${length(var.az_zone)}" ## You would imagine this thing will do things in the right AZ

  device_name  = "${var.device_mount_path}"
  volume_id    = "${element(aws_ebs_volume.promethues-disk.*.id, count.index)}"
  instance_id  = "${element(aws_instance.prometheus.*.id, count.index)}"
  skip_destroy = true
}

resource "aws_ebs_volume" "promethues-disk" {
  count = "${length(var.az_zone)}"
  
  availability_zone = "${element(var.az_zone, count.index)}"
  size              = "20"

  tags {
    Name = "promethues-disk"
  }
}

data "template_file" "user_data_script" {
  template = "${file("${path.module}/cloud.conf")}"

  vars {
    prometheus_version = "${var.prometheus_version}"
    config_bucket      = "${aws_s3_bucket.prometheus_config.id}"
  }
}


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

resource "aws_s3_bucket" "prometheus_config" {
  bucket = "prometheus-config-store"
  acl    = "private"

  versioning {
    enabled = true
  }
}