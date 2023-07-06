locals {
  root_graph = {for k, v in var.platform_bootstrap_graph : k => v if contains(var.platform_bootstrap_graph_root_type, v["type"])}
  root_graph_nodes_filtered = flatten([ for k, v in values(local.root_graph) :  [ for nk, nv in v["nodes"] : {
    tenant : nk, fqdn : nv["label"], domains: nv["domains"]
  } ] ])
  root_graph_nodes = [ for n in local.root_graph_nodes_filtered : ([n["tenant"], n["fqdn"], n["domains"]]) if length(n) > 0]
}