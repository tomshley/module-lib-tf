terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.53.0"
    }

    # https://letsencrypt.org/docs/client-options/ -> Terraform ACME Provider: https://registry.terraform.io/providers/vancluever/acme/latest
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.10.0"
    }
  }
}