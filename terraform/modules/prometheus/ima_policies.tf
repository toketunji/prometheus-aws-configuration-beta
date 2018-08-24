#Instance profile
resource "aws_iam_instance_profile" "prometheus_instance_profile" {
  name = "prometheus_config_policy"
  role = "${aws_iam_role.prometheus_role.name}"
}

resource "aws_iam_role" "prometheus_role" {
  name = "prometheus_profile"
  description = "This profile is used to ensure prometheus can describe instances and grab config from the bucket"

  assume_role_policy = "${data.aws_iam_policy_document.prometheus_assume_role_policy.json}"
}

data "aws_iam_policy_document" "prometheus_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "iam_policy" {
  role       = "${aws_iam_role.prometheus_role.name}"
  policy_arn = "${aws_iam_policy.prometheus_instance_profile.arn}"
}


resource "aws_iam_policy" "prometheus_instance_profile" {
  name        = "prometheus_instance_profile"
  path        = "/"
  description = "This is the main profile, that has bucket permission and decribe permissions"

  policy = "${data.aws_iam_policy_document.instance_role_policy.json}"
}

##

data "aws_iam_policy_document" "instance_role_policy" {

  statement {
    sid = "ec2Policy"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    sid = "s3Bucket"
    actions = [
      "s3:Get*",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.prometheus_config.id}/*",
      "arn:aws:s3:::${aws_s3_bucket.prometheus_config.id}",
    ]

  }
}