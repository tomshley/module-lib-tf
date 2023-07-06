output "godaddy_domain_records" {
  depends_on = [godaddy_domain_record.primary_zones]
  value = godaddy_domain_record.primary_zones
}