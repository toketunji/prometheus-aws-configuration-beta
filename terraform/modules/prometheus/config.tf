data "template_file" "user_data_script" {
  template = "${file("${path.module}/cloud.conf")}"

  vars {
    prometheus_version = "${var.prometheus_version}"
    config_bucket      = "${aws_s3_bucket.prometheus_config.id}"
  }
}

resource "aws_s3_bucket" "prometheus_config" {
  bucket = "prometheus-config-store"
  acl    = "private"

  versioning {
    enabled = true
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