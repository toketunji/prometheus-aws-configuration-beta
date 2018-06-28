terraform {
  required_version = "= 0.11.7"

  backend "s3" {
    key = "govuk-re-tools-pagerduty.tfstate"
  }
}

variable pagerduty_token {
  description = "The api token to authenticate with Pagerduty configure by setting the environment variable `TF_VAR_pagerduty_token`"
}

variable oncall_phonenumber {
  description = "The phone number of the oncall person, *note* drop the leading 0, configure by setting the environment variable `TF_VAR_oncall_phone`"
}

variable oncall_name {
  description = "The name of the oncall person configure by setting the environment variable `TF_VAR_oncall_name`"
}

provider "pagerduty" {
  token = "${var.pagerduty_token}"
}

resource "pagerduty_team" "re-tools-support" {
  name        = "RE Tools Support"
  description = ""
}

resource "pagerduty_user" "oncall-user" {
  name        = "RE Tools Team"
  description = ""
  email       = "prometheus-notifications@digital.cabinet-office.gov.uk"
  teams       = ["${pagerduty_team.re-tools-support.id}"]
}

resource "pagerduty_user_contact_method" "gmail-group" {
  user_id = "${pagerduty_user.oncall-user.id}"
  type    = "email_contact_method"
  address = "prometheus-notifications@digital.cabinet-office.gov.uk"
  label   = "Google Group"
}

resource "pagerduty_user_contact_method" "oncall-phone" {
  user_id      = "${pagerduty_user.oncall-user.id}"
  type         = "phone_contact_method"
  country_code = "+44"
  address      = "${var.oncall_phonenumber}"
  label        = "${var.oncall_name}"
}

resource "pagerduty_escalation_policy" "production" {
  name  = "Re Tools Team Production"
  teams = ["${pagerduty_team.re-tools-support.id}"]

  description = ""

  rule {
    escalation_delay_in_minutes = 30

    target {
      type = "schedule_reference"
      id   = "${pagerduty_schedule.interrupt-rota.id}"
    }
  }
}

resource "pagerduty_schedule" "interrupt-rota" {
  name        = "RE Tools Support (In Hours Interrupt Rota)"
  time_zone   = "Europe/London"
  description = ""

  layer {
    name                         = "In Hours Support"
    start                        = "2018-06-28T09:25:42+01:00"
    rotation_virtual_start       = "2018-06-27T09:00:00+01:00"
    rotation_turn_length_seconds = 604800
    users                        = ["${pagerduty_user.oncall-user.id}"]

    restriction {
      type              = "weekly_restriction"
      start_day_of_week = 1                    #Monday 
      start_time_of_day = "09:00:00"
      duration_seconds  = 32400                # 18:00:00 9 Hours
    }

    restriction {
      type              = "weekly_restriction"
      start_day_of_week = 2                    #Tuesday 
      start_time_of_day = "09:00:00"
      duration_seconds  = 32400                # 18:00:00 9 Hours
    }

    restriction {
      type              = "weekly_restriction"
      start_day_of_week = 3                    #Wednesday
      start_time_of_day = "09:00:00"
      duration_seconds  = 32400                # 18:00:00 9 Hours
    }

    restriction {
      type              = "weekly_restriction"
      start_day_of_week = 4                    #Thursday
      start_time_of_day = "09:00:00"
      duration_seconds  = 32400                # 18:00:00 9 Hours
    }

    restriction {
      type              = "weekly_restriction"
      start_day_of_week = 5                    #Friday
      start_time_of_day = "09:00:00"
      duration_seconds  = 32400                # 18:00:00 9 Hours
    }
  }
}
