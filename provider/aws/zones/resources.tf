locals {
  flattened_cnames_prep = flatten([
    for k, v in var.platform_bootstrap_dns_fqdn_records : [
      for k1, v1 in flatten(v) : {
        cname : keys(v1)[0],     value : values(v1)[0],     zone_name : k
      }
    ]
  ])
  flattened_cnames = {
    for k, v in local.flattened_cnames_prep : k => v
  }
}

resource "aws_route53_zone" "primary_zone" {
  for_each = var.platform_bootstrap_dns_fqdn_records
  name     = each.key
  tags = {
    for v in flatten(each.value) : keys(v)[0] => values(v)[0]
  }
}

#resource "aws_route53_record" "cname" {
#  for_each = local.flattened_cnames
#  name    = each.value["cname"]
#  records = [each.value["value"]]
#  type    = "CNAME"
#  zone_id = [for k, v in aws_route53_zone.primary_zone : v.id if v.name == each.value["zone_name"]][0]
#  ttl = 5
#}