locals {
  cert_prep = [
    for v in concat([
      for k1, v1 in acme_certificate.certificate :
      [[k1, "${k1}/certificate_pem"], [k1, "${k1}/issuer_pem"], [k1, "${k1}/private_key_pem"]]
    ]) : {for v2 in v : v2[1] => v2[0]}
  ]
  cert_prep_keys   = flatten([for k, v in local.cert_prep : keys(v)])
  cert_prep_values = flatten([for k, v in local.cert_prep : values(v)])
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "active_primary_zones" {
  depends_on = [var.platform_provider_aws_zones]
  for_each = var.platform_provider_aws_zones
  zone_id     = each.value.zone_id
}

resource "tls_private_key" "private_key" {
  depends_on = [var.platform_provider_aws_zones, data.aws_route53_zone.active_primary_zones]
  for_each   = data.aws_route53_zone.active_primary_zones
  algorithm  = "RSA"
}

resource "acme_registration" "registration" {
  for_each        = tls_private_key.private_key
  account_key_pem = each.value.private_key_pem
  email_address   = var.platform_provider_aws_encrypt_email
}

data "aws_route53_zone" "base_domain" {
  for_each = acme_registration.registration
  name     = data.aws_route53_zone.active_primary_zones[each.key].name
}

resource "acme_certificate" "certificate" {
  for_each                  = acme_registration.registration
  account_key_pem           = each.value.account_key_pem
  common_name               = each.key
  subject_alternative_names = ["*.${each.key}"]
  #  subject_alternative_names = distinct(flatten([[for k, v in flatten([for k2, v2 in var.platform_bootstrap_dns_fqdn_records : [
  #    for k1, v1 in flatten(v2) : {
  #      cname : format("%s.%s", keys(v1)[0], k2),
  #      value : format("%s.%s", values(v1)[0], k2),
  #      zone_name : k2
  #    } if k2 == each.key
  #  ]]): [v["cname"], v["value"]]]]))

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID    = data.aws_route53_zone.base_domain[each.key].id
      AWS_ACCESS_KEY_ID     = var.platform_provider_aws_key
      # this config requires the plain text info... TODO - investigate a better way
      AWS_SECRET_ACCESS_KEY = var.platform_provider_aws_secret
      # this config requires the plain text info... TODO - investigate a better way
      AWS_DEFAULT_REGION    = var.platform_provider_aws_region
      # this config requires the plain text info... TODO - investigate a better way
    }
  }

  depends_on = [aws_s3_bucket.cert_store, acme_registration.registration, data.aws_route53_zone.base_domain, data.aws_caller_identity.current]
}

resource "aws_s3_bucket" "cert_store" {
  bucket = "global-root.tlib.tf.hexagonal.aws.encrypt"
}

resource "aws_s3_object" "certificate_artifacts_s3_objects" {
  depends_on = [
    aws_s3_bucket.cert_store,
    acme_certificate.certificate,
    aws_s3_bucket_policy.state_bucket_policy,
    aws_s3_bucket_versioning.cert_store_versioning,
    aws_s3_bucket_server_side_encryption_configuration.cert_store_config,
    data.aws_iam_policy_document.state_bucket_policy_document
  ]
  for_each   = zipmap(local.cert_prep_keys, local.cert_prep_values)
  bucket     = aws_s3_bucket.cert_store.id
  key        = "certs/${each.key}"
  content    = lookup(acme_certificate.certificate[each.value], trimprefix(each.key, "${each.value}/"))
}

resource "aws_s3_bucket_policy" "state_bucket_policy" {
  depends_on = [aws_s3_bucket.cert_store]
  bucket     = aws_s3_bucket.cert_store.id
  policy     = data.aws_iam_policy_document.state_bucket_policy_document.json
}

data "aws_iam_policy_document" "state_bucket_policy_document" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.cert_store.arn, "${aws_s3_bucket.cert_store.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_versioning" "cert_store_versioning" {
  depends_on = [aws_s3_bucket.cert_store]
  bucket     = aws_s3_bucket.cert_store.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cert_store_config" {
  depends_on = [aws_s3_bucket.cert_store]
  bucket     = aws_s3_bucket.cert_store.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}