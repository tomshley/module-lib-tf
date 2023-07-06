variable "platform_bootstrap_dns_fqdn_records" {
  description = "graph root directories"
  type        = any # todo - make this nicer, it's lame-ish
}

variable "platform_provider_aws_zones" {
  type = any
}

variable "platform_provider_aws_region" {
  type = string
}

variable "platform_provider_aws_key" {
  type = string
}

variable "platform_provider_aws_secret" {
  type = string
}

variable "platform_provider_aws_encrypt_email" {
  type = string
}