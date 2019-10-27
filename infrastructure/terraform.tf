terraform {
  required_version = ">= 0.12.6"
}

provider "cloudflare" {
  version = "~> 2.0"
}

terraform {
  backend "s3" {
    bucket = "terraform-fstaffa"
    region = "eu-west-1"
    key    = "filipstaffa.net"
  }
}
