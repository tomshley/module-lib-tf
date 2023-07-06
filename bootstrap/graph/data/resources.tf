locals {
  # WARNING! There is no error handling or validation here. Use cautiously

  # get json
  graph_data = jsondecode(file(var.platform_bootstrap_graph_source))

  # get all users
  graphs = {for node in local.graph_data["graphs"] : node["id"] => node }

}

# variable "hostname" { default = "ad.yourdomain.com" }
# variable "username" { default = "user" }
# variable "password" { default = "password" }
#
# // remote using Basic authentication
# provider "ad" {
#   winrm_hostname = var.hostname
#   winrm_username = var.username
#   winrm_password = var.password
# }
#
# // remote using NTLM authentication
# provider "ad" {
#   winrm_hostname = var.hostname
#   winrm_username = var.username
#   winrm_password = var.password
#   winrm_use_ntlm = true
# }
#
# // remote using NTLM authentication and HTTPS
# provider "ad" {
#   winrm_hostname = var.hostname
#   winrm_username = var.username
#   winrm_password = var.password
#   winrm_use_ntlm = true
#   winrm_port     = 5986
#   winrm_proto    = "https"
#   winrm_insecure = true
# }
#
# // remote using Kerberos authentication
# provider "ad" {
#   winrm_hostname = var.hostname
#   winrm_username = var.username
#   winrm_password = var.password
#   krb_realm      = "YOURDOMAIN.COM"
# }
#
# // remote using Kerberos authentication with krb5.conf file
# provider "ad" {
#   winrm_hostname = var.hostname
#   winrm_username = var.username
#   winrm_password = var.password
#   krb_conf       = "/etc/krb5.conf"
# }
#
# // local (windows only)
# provider "ad" {
#   winrm_hostname = ""
#   winrm_username = ""
#   winrm_password = ""
# }