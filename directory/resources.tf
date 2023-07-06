module "platform_bootstrap_graph_core_graph_data" {
  source                  = "../bootstrap/graph/root"
  platform_bootstrap_graph           = var.platform_bootstrap_graph
  platform_bootstrap_graph_root_type = var.platform_bootstrap_graph_root_type
}

locals {
  graph_templates = {
    for k, v in var.platform_bootstrap_graph : k =>
    {for nk, nv in v["nodes"] : nk => {} if contains(var.ou_nested_template, v["type"])}
    if contains(var.ou_filter, v["type"])
  }

  ou_primordial_template = {
    (var.primordial_ou_label) : {
      (var.primordial_deprecated_ou_label) : local.graph_templates
      (var.primordial_staged_ou_label) : local.graph_templates
    }
  }


  fqdns         = [
    for t in module.platform_bootstrap_graph_core_graph_data.root_graph_nodes : flatten(["dir.${t[1]}", t[1], t[2]])
    if contains(var.graph_root_filter, t[0])
  ]
  fqdns_ordered = concat([for f in local.fqdns : flatten([slice(f, 2, length(f)), slice(f, 1, 2)])])
  directories   = tomap({
    for d in local.fqdns : d[0] => {
      domains : local.fqdns_ordered,   operational_units : merge(local.graph_templates, local.ou_primordial_template)
    }
  })
}