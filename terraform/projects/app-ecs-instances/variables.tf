variable "additional_tags" {
  type        = "map"
  description = "Stack specific tags to apply"
  default     = {}
}

variable "aws_region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

variable "autoscaling_group_min_size" {
  type        = "string"
  description = "Minimum desired number of ECS container instances"
  default     = 1
}

variable "autoscaling_group_max_size" {
  type        = "string"
  description = "Maximum desired number of ECS container instances"
  default     = 1
}

variable "autoscaling_group_desired_capacity" {
  type        = "string"
  description = "Desired number of ECS container instances"
  default     = 1
}

variable "ecs_image_id" {
  type        = "string"
  description = "AMI ID to use for the ECS container instances"
  default     = "ami-2d386654"                                  # Latest Amazon ECS optimised AMI
}

variable "ecs_instance_type" {
  type        = "string"
  description = "ECS container instance type"
  default     = "m4.xlarge"
}

variable "ecs_instance_root_size" {
  type        = "string"
  description = "ECS container instance root volume size - in GB"
  default     = "50"
}

variable "ecs_instance_ssh_keyname" {
  type        = "string"
  description = "SSH keyname for ECS container instances"
  default     = "djeche-insecure"
}

variable "remote_state_bucket" {
  type        = "string"
  description = "S3 bucket we store our terraform state in"
  default     = "ecs-monitoring"
}

variable "stack_name" {
  type        = "string"
  description = "Unique name for this collection of resources"
  default     = "ecs-monitoring"
}

# locals
# --------------------------------------------------------------

locals {
  default_tags = {
    Terraform = "true"
    Project   = "app-ecs-instances"
  }

  cluster_name = "${var.stack_name}-ecs-monitoring"
}

## Providers

terraform {
  required_version = "= 0.11.7"

  backend "s3" {
    key = "app-ecs-instances.tfstate"
  }
}

provider "aws" {
  version = "~> 1.14.1"
  region  = "${var.aws_region}"
}

provider "template" {
  version = "~> 1.0.0"
}

## Data sources

data "terraform_remote_state" "infra_networking" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    key    = "infra-networking.tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "infra_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    key    = "infra-security-groups.tfstate"
    region = "${var.aws_region}"
  }
}

## Outputs

output "ecs_instance_asg_id" {
  value       = "${module.ecs_instance.this_autoscaling_group_id}"
  description = "ecs-instance ASG ID"
}

output "cluster_arn" {
  value       = "${aws_ecs_cluster.prometheus_cluster.arn}"
  description = "PrometheusCLuster ARN"
}
