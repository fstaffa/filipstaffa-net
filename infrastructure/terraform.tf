terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 2.15"
    }
  }
  required_version = ">= 0.13"
}

terraform {
  backend "s3" {
    bucket = "terraform-fstaffa"
    region = "eu-west-1"
    key    = "filipstaffa.net"
  }
}
