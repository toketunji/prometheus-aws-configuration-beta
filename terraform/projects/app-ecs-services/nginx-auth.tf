## IAM roles & policies


### container, task, service definitions

data "template_file" "nginx_auth_container_def" {
  template = "${file("task-definitions/standalone-auth.json")}"

  vars {
    log_group     = "${aws_cloudwatch_log_group.task_logs.name}"
    region        = "${var.aws_region}"
    alertmanager_1_dns_name = "${data.terraform_remote_state.app_ecs_albs.alerts_private_record_fqdns.0}"
    alertmanager_2_dns_name = "${data.terraform_remote_state.app_ecs_albs.alerts_private_record_fqdns.1}"
    alertmanager_3_dns_name = "${data.terraform_remote_state.app_ecs_albs.alerts_private_record_fqdns.2}"
    prometheus_1_dns_name = "${data.terraform_remote_state.app_ecs_albs.prom_private_record_fqdns.0}"
    prometheus_2_dns_name = "${data.terraform_remote_state.app_ecs_albs.prom_private_record_fqdns.1}"
    prometheus_3_dns_name = "${data.terraform_remote_state.app_ecs_albs.prom_private_record_fqdns.2}"
  }
}

resource "aws_ecs_task_definition" "nginx_auth_server" {
  family                = "${var.stack_name}-nginx-auth"
  container_definitions = "${data.template_file.nginx_auth_container_def.rendered}"
  task_role_arn         = "${aws_iam_role.alertmanager_task_iam_role.arn}"

  volume {
    name      = "auth-proxy"
    host_path = "/ecs/config-from-s3/auth-proxy/conf.d"
  }
}

resource "aws_ecs_service" "nginx_auth_service" {
  name            = "${var.stack_name}-nginx-auth"
  cluster         = "${var.stack_name}-ecs-monitoring"
  task_definition = "${aws_ecs_task_definition.nginx_auth_server.arn}"
  desired_count   = 3

  load_balancer {
    target_group_arn = "${data.terraform_remote_state.app_ecs_albs.st_nginx_proxy_tg}"
    container_name   = "auth-proxy"
    container_port   = 8181
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
}

#### alertmanager

