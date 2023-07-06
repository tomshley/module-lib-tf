module "platform_bootstrap_graph_core_graph_data" {
  source                             = "../bootstrap/graph/root"
  platform_bootstrap_graph           = var.platform_bootstrap_graph
  platform_bootstrap_graph_root_type = var.platform_bootstrap_graph_root_type
}

locals {
  fqdn_prep = {
    for n in module.platform_bootstrap_graph_core_graph_data.root_graph_nodes : n[0] => ([
      n[1],   split(".", n[1]),   n[2]
    ])
  }

  # + global                            = [
  #  + "global.root.tenancy.tware.tech",
  #  + [
  #+ "global",
  #+ "root",
  #+ "tenancy",
  #+ "tware",
  #+ "tech",
  #],
  #+ [
  #+ "tware.io",
  #+ "tware.email",
  #+ "tware.cloud",
  #+ "tware.dev",
  #+ "tware.email",
  #],
  #]

  fqdns_grouped = flatten([
    for k, v in local.fqdn_prep : flatten([
      for d in distinct(flatten([
        [
          join(".", [
            element(v[1], length(v[1])-2),         element(v[1], length(v[1])-1)
          ])
        ],     v[2]
      ])) : {
        fqdn : d,     tenant : [k]
      }
    ])
  ])
  fqdns_merged        = merge({for k, v in local.fqdns_grouped : v["fqdn"] => v["tenant"]...})
  fqdn_tenant_records = {
    for k, v in local.fqdns_grouped : v["fqdn"] => {
      for v1 in v["tenant"] : format(
          "%s%s",       endswith(
            join(".", local.fqdn_prep[v1][1]),         v["fqdn"]
          ) ?
          trimsuffix(join(".", local.fqdn_prep[v1][1]), format(".%s", v["fqdn"])) : "",       endswith(
            join(".", local.fqdn_prep[v1][1]),         v["fqdn"]
          ) ? "" : join("-", local.fqdn_prep[v1][1]),       ) =>
        endswith(
          join(".", local.fqdn_prep[v1][1]), v["fqdn"]
        ) ? format("%s.%s",       trimsuffix(join("-", local.fqdn_prep[v1][1]), "-tware-tech"),       v["fqdn"]
        ) : join(".", local.fqdn_prep[v1][1])
    }...
  }
  # + "rajant.com"    = [
  #  + [
  #    + "global-usa-rajantcorp",
  #],
  #]
  fqdns           = {for k, v in local.fqdns_merged : k => distinct(flatten(v))}
  fqdn_roots_only = distinct(flatten([for k, v in local.fqdns : k]))
}