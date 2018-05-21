/**
* ECS service that runs prometheus
*
* This service consists of two containers.  The first, `s3-config-grabber`, fetches prometheus configuration from our config S3 bucket, and stores it on a shared volume.  Then `prometheus` runs and consumes that config.
*
* There is a known race condition between the two tasks - there is no guarantee that `s3-config-grabber` will grab the config before `prometheus` starts.
*
*/

### container, task, service definitions ###

########### Prometheus ECS service #############
# ----------------------------------------------

##### Task defintion #####
data "template_file" "prometheus_container_defn" {
  template = "${file("task-definitions/prometheus-server.json")}"

  vars {
    log_group     = "${aws_cloudwatch_log_group.task_logs.name}"
    region        = "${var.aws_region}"
    config_bucket = "${aws_s3_bucket.config_bucket.id}"
  }
}

resource "aws_ecs_task_definition" "prometheus_server" {
  family                = "${var.stack_name}-prometheus-server"
  container_definitions = "${data.template_file.prometheus_container_defn.rendered}"
  task_role_arn         = "${aws_iam_role.prometheus_task_iam_role.arn}"

  volume {
    name      = "config-from-s3"
    host_path = "/ecs/config-from-s3"
  }

  volume {
    name      = "prometheus-config"
    host_path = "/ecs/config-from-s3/prometheus/prometheus.yml"
  }

  volume {
    name      = "alert-config"
    host_path = "/ecs/config-from-s3/prometheus/alerts"
  }
}

##### Service defintion #####
resource "aws_ecs_service" "prometheus_server" {
  name            = "${var.stack_name}-prometheus"
  cluster         = "${var.stack_name}-ecs-monitoring"
  task_definition = "${aws_ecs_task_definition.prometheus_server.arn}"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${data.terraform_remote_state.app_ecs_albs.monitoring_external_tg}"
    container_name   = "prometheus"
    container_port   = 9090
  }
}

########### Configurator ECS service ############
#----------------------------------------------

##### Task defintion #####

data "template_file" "s3_configurator" {
  template = "${file("task-definitions/configurator.json")}"

  vars {
    log_group     = "${aws_cloudwatch_log_group.task_logs.name}"
    region        = "${var.aws_region}"
    config_bucket = "${aws_s3_bucket.config_bucket.id}"
  }
}

resource "aws_ecs_task_definition" "s3_configurator" {
  family                = "${var.stack_name}-s3configurator"
  container_definitions = "${data.template_file.s3_configurator.rendered}"
  task_role_arn         = "${aws_iam_role.prometheus_task_iam_role.arn}"

  volume {
    name      = "config-from-s3"
    host_path = "/srv/gds/"
  }
}

##### Service defintion #####

resource "aws_ecs_service" "s3-config-svc" {
  name            = "${var.stack_name}-s3-config-svc"
  cluster         = "${var.stack_name}-ecs-monitoring"
  task_definition = "${aws_ecs_task_definition.s3_configurator.arn}"
  desired_count   = 1
}

########### Targets ECS service #############
#--------------------------------------------

##### Task defintion #####

data "template_file" "s3_targets" {
  template = "${file("task-definitions/targets.json")}"

  vars {
    log_group      = "${aws_cloudwatch_log_group.task_logs.name}"
    region         = "${var.aws_region}"
    config_bucket  = "${aws_s3_bucket.config_bucket.id}"
    targets_bucket = "${var.prometheus_targets_bucket}"
  }
}

resource "aws_ecs_task_definition" "s3_targets" {
  family                = "${var.stack_name}-s3targets"
  container_definitions = "${data.template_file.s3_targets.rendered}"

  # container permissions need to be worked out
  # task_role_arn         = "${aws_iam_role.prometheus_task_iam_role.arn}"

  volume {
    name      = "config-from-s3"
    host_path = "/srv/gds/"
  }
}

##### Service defintion #####

resource "aws_ecs_service" "s3-targets-svc" {
  name            = "${var.stack_name}-s3-targets-svc"
  cluster         = "${var.stack_name}-ecs-monitoring"
  task_definition = "${aws_ecs_task_definition.s3_targets.arn}"
  desired_count   = 1
}

##### Config uploader ####


#look at for uplaoding folder via aws cli & local exec

