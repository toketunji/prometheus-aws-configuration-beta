terraform {
  required_version = ">= 0.11.2"
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
