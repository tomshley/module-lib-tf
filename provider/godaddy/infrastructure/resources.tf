data "aws_route53_zone" "aws_active_fqdn_zones" {
  depends_on = [var.platform_provider_aws_zones]
  for_each = var.platform_provider_aws_zones
  zone_id     = each.value.zone_id
}

resource "godaddy_domain_record" "primary_zones" {
  depends_on = [data.aws_route53_zone.aws_active_fqdn_zones]
  for_each = data.aws_route53_zone.aws_active_fqdn_zones
  domain   = each.key

  // required if provider key does not belong to customer
  customer = var.platform_provider_godaddy_customer

  // specify any custom nameservers for your domain
  // note: godaddy now requires that the 'custom' nameservers are first supplied through the ui
  nameservers = each.value.name_servers
}