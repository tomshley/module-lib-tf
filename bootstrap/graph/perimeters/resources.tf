locals {
  root_graph_prep = {for k, v in var.platform_bootstrap_graph : k => v if contains(var.platform_bootstrap_graph_root_type, v["type"])}
  root_graph_keys = flatten([ for k, v in local.root_graph_prep : keys({ for k1, v1 in v["nodes"] : k1 => v1["label"]})])
  root_graph_values = flatten([ for k, v in local.root_graph_prep : values({ for k1, v1 in v["nodes"] : k1 => v1["label"]})])
  root_graph = zipmap(local.root_graph_keys, local.root_graph_values)

  perimeter_graph = {for k, v in var.platform_bootstrap_graph : k => v if contains(var.platform_bootstrap_graph_perimeters_type, v["type"])}
  perimeter_graph_edges = one([ for k, v in local.perimeter_graph : merge({ for k1, v1 in v : k1 => v1 if k1 == "edges"})][*]["edges"])
  perimeter_graph_nodes = one([ for k, v in local.perimeter_graph : merge({ for k1, v1 in v : k1 => v1 if k1 == "nodes" })][*]["nodes"])


  perimeter_relationship_fqdns = [for k, v in local.perimeter_graph_edges : format("%s.%s", replace(local.perimeter_graph_nodes[v["target"]]["label"], "-", "."), local.root_graph[local.perimeter_graph_nodes[v["source"]]["label"]]) if contains(keys(local.root_graph), local.perimeter_graph_nodes[v["source"]]["label"])] #[ for k, v in values(local.perimeter_graph)[*]["edges"] : []]
  perimeter_relationship_fqdn_sources = [for k, v in local.perimeter_graph_edges : format("%s-%s", local.perimeter_graph_nodes[v["target"]]["label"], local.perimeter_graph_nodes[v["source"]]["label"]) if contains(keys(local.root_graph), local.perimeter_graph_nodes[v["source"]]["label"])] #[ for k, v in values(local.perimeter_graph)[*]["edges"] : []]
  perimeters = zipmap(local.perimeter_relationship_fqdn_sources, local.perimeter_relationship_fqdns)
}