output "prometheus_dns" {
  value = "${module.Prometheus.prometheus_public_dns}"
}

output "prometheus_id" {
  value = "${element(module.Prometheus.prometheus_instance_id, 0)}"
}

output "prom_s3_config_bucket" {
  value = "${module.Prometheus.s3_config_bucket}"
}

