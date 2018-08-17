terraform {
  backend "s3" {
    bucket = "infra-dj"
    key    = "terraform/state"
  }
}
