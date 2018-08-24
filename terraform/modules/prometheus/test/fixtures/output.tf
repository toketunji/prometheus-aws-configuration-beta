output "myvalues" {
  value = "${module.vpc.vpc_id}"
}

output "promtheus_server_ip" {
  description = "The instance IP address"

  value = "${module.prometheus.promtheus_server_ip}"
}