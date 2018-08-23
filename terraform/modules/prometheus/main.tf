terraform {
  required_version = ">= 0.11.2"
}

resource "aws_instance" "prometheus" {
  count = "${length(keys(var.subnets))}"

  ami                  = "${module.ubuntu.ami_id}"
  instance_type        = "${var.instance_size}"
  user_data            = "${data.template_file.user_data_script.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.prometheus_instance_profile.id}"
  subnet_id            = "${element(var.subnets, count.index)}"

  key_name             = "${var.ssh_key_name}"

  vpc_security_group_ids = [
    "${var.vpc_security_groups}",
  ]

  tags {
    Name          = "${var.product}-${var.environment}-prometheus-${element(keys(var.availablity_zones), count.index)}"
    Environment   = "${var.environment}"
    Product       = "${var.product}"
    ManagedBy     = "terraform"
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

