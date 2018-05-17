/**
* ## Project: infra-security-groups
*
* Central project to manage all security groups.
*
* This is done in a single project to reduce conflicts
* and cascade issues.
*
*
*/

## Resources

### External SG

resource "aws_security_group" "monitoring_external_sg" {
  name        = "${var.stack_name}-monitoring-external-sg"
  vpc_id      = "${data.terraform_remote_state.infra_networking.vpc_id}"
  description = "Controls external access to the LBs"
}

resource "aws_security_group_rule" "monitoring_external_sg_ingress_any_http" {
  type              = "ingress"
  to_port           = 80
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.monitoring_external_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "monitoring_external_sg_egress_any_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.monitoring_external_sg.id}"
}

### Internal SG

resource "aws_security_group" "monitoring_internal_sg" {
  name        = "${var.stack_name}-monitoring-internal-sg"
  vpc_id      = "${data.terraform_remote_state.infra_networking.vpc_id}"
  description = "Controls access to the ECS container instance from the LBs"
}

resource "aws_security_group_rule" "monitoring_internal_sg_ingress_alb_http" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"

  security_group_id        = "${aws_security_group.monitoring_internal_sg.id}"
  source_security_group_id = "${aws_security_group.monitoring_external_sg.id}"
}

resource "aws_security_group_rule" "monitoring_internal_sg_egress_any_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.monitoring_internal_sg.id}"
}
