terraform {
  required_version = "= 0.11.7"

  backend "s3" {
    key = "govuk-re-tools-pagerduty.tfstate"
  }
}

variable pagerduty_token {}

provider "pagerduty" {
  token = "${var.pagerduty_token}"
}

resource "pagerduty_team" "re-tools-support" {
  name        = "RE Tools Support"
  description = ""
}

resource "pagerduty_user" "tools-team" {
  name  = "RE Tools Team"
  description = ""
  email = "prometheus-notifications@digital.cabinet-office.gov.uk"
  teams = ["${pagerduty_team.re-tools-support.id}"]
}


