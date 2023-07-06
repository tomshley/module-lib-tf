output "flattened_cnames" {
  value = local.flattened_cnames
}

output "primary_zones_zones" {
  depends_on = [aws_route53_zone.primary_zone]
  value = aws_route53_zone.primary_zone
}
