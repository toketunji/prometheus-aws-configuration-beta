output "data" {
  value = "${data.template_file.user_data_script.rendered}"
}

output "promtheus_server_ip" {
  description = "The instance IP address"

  value = "${element(aws_instance.prometheus.*.public_dns, 0)}"
}

output "prom_security_groups" {
  value = [
    "${aws_security_group.ssh_from_gds.id}",
    "${aws_security_group.http_outbound.id}",
    "${aws_security_group.external_http_traffic.id}",
  ]
}
