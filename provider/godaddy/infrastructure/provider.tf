terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.53.0"
    }

    godaddy = {
      source  = "n3integration/godaddy"
      version = "~> 1.9.1"
    }
  }
}