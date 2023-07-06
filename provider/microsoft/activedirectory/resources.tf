resource "ad_ou" "root_ou" {
  for_each    = tomap(var.platform_bootstrap_graph_directories)
  name        = each.key
  path        = join(",", [for k in split(".", each.key) : "dc=${k}"])
  description = "OU generated"
  protected   = false
}