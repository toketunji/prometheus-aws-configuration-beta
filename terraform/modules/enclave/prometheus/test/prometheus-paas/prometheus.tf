module "prometheus" {
  source = "../../../prometheus"

  # Canonicals Ubunutu 18.04 Bionic Beaver in eu-west-1
  ami_id     = "ami-0ee06eb8d6eebcde0"
  target_vpc = "${module.vpc.vpc_id}"
  enable_ssh = true

  product        = "${local.product}"
  environment    = "${local.environment}"
  config_bucket  = "${local.environment}"
  targets_bucket = "gds-prometheus-targets-dev"

  prometheus_public_fqdns = "${var.prometheus_public_fqdns}"

  subnet_ids = "${module.vpc.public_subnets}"

  availability_zones = "${local.availability_zones}"

  vpc_security_groups = ["${aws_security_group.permit_internet_access.id}"]
}

module "paas-config" {
  source = "../../../paas-config"

  environment              = "${local.environment}"
  prometheus_config_bucket = "${module.prometheus.s3_config_bucket}"
  alertmanager_dns_names   = "${join("\",\"", local.active_alertmanager_private_fqdns)}"
  alerts_path              = "${path.module}/../../../../../projects/app-ecs-services/config/alerts/"

  prom_private_ips  = "${module.prometheus.private_ip_addresses}"
  private_zone_id   = "${aws_route53_zone.private.zone_id}"
  private_subdomain = "${aws_route53_zone.private.name}"

  paas_proxy_sg_id = "${aws_security_group.permit_internet_access.id}"
  prometheus_sg_id = "${module.prometheus.ec2_instance_prometheus_sg}"
}
