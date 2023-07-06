#output "certificate_pem" {
#  value = lookup(acme_certificate.certificate, "certificate_pem")
#}
#
#output "issuer_pem" {
#  value = lookup(acme_certificate.certificate, "issuer_pem")
#}
#
#output "private_key_pem" {
#  value = nonsensitive(lookup(acme_certificate.certificate, "private_key_pem"))
#}
#
#output "canonical_user_id" {
#  value = data.aws_canonical_user_id.current.id
#}