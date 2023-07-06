module "platform_bootstrap_graph_core_graph_data" {
  source                             = "../graph/root"
  platform_bootstrap_graph           = var.platform_bootstrap_graph
  platform_bootstrap_graph_root_type = var.platform_bootstrap_graph_root_type
}

locals {
  rel_file_path = "tenancy-generated/tf-hexagonal/tenancy"
  remote_state_fqdns = {
    for k, v in module.platform_bootstrap_graph_core_graph_data.root_graph_nodes : v[0] =>
    join("-", reverse(split(".", v[1])))
  }

  remote_state_providers = {
    for k, v in local.
    remote_state_fqdns : k => {
      backend : "http",   rel_path : v,   config : {
        tf_name = replace(v, "-", "_")
        id       = var.state_identifier,     host     = var.state_remote_host,     address  = "${var.state_remote_host}/api/v4/projects/${var.state_identifier}/terraform/state/${v}",     username = var.state_username,     password = var.state_access_token
      }
    }
  }
}

resource "local_file" "gitignore" {
  for_each = local.remote_state_providers
  content  = templatefile("${path.module}/templates/.gitignore.tftpl", each.value["config"])
  filename = "${var.root_path}/${local.rel_file_path}/${each.value["rel_path"]}/.gitignore"
}

resource "local_file" "makefile" {
  for_each = local.remote_state_providers
  content  = templatefile("${path.module}/templates/makefile.tftpl", each.value["config"])
  filename = "${var.root_path}/${local.rel_file_path}/${each.value["rel_path"]}/makefile"
}

resource "local_file" "main_tf" {
  for_each = local.remote_state_providers
  content  = templatefile("${path.module}/templates/hexagonal.platform.bootstrap.state.backend.tf.tftpl", each.value["config"])
  filename = "${var.root_path}/${local.rel_file_path}/${each.value["rel_path"]}/hexagonal.platform.bootstrap.state.backend.tf"
}

resource "local_file" "variables_tf" {
  for_each = local.remote_state_providers
  content  = templatefile("${path.module}/templates/hexagonal.platform.bootstrap.state.variables.tf.tftpl", each.value["config"])
  filename = "${var.root_path}/${local.rel_file_path}/${each.value["rel_path"]}/hexagonal.platform.bootstrap.state.variables.tf"
}

resource "local_file" "data_tf" {
  for_each = local.remote_state_providers
  content  = templatefile("${path.module}/templates/hexagonal.platform.bootstrap.state.data.tf.tftpl", each.value["config"])
  filename = "${var.root_path}/${local.rel_file_path}/${each.value["rel_path"]}/hexagonal.platform.bootstrap.state.data.tf"
}

resource "local_sensitive_file" "tfstate_env" {
  for_each = local.remote_state_providers
  content  = templatefile("${path.module}/templates/.hexagonal.platform.bootstrap.state.env.tftpl", each.value["config"])
  filename = "${var.root_path}/${local.rel_file_path}/${each.value["rel_path"]}/.hexagonal.platform.bootstrap.state.env"
}


resource "local_sensitive_file" "tfstate_env_example" {
  for_each = local.remote_state_providers
  content  = templatefile("${path.module}/templates/.hexagonal.platform.bootstrap.state.env.example.tftpl", each.value["config"])
  filename = "${var.root_path}/${local.rel_file_path}/${each.value["rel_path"]}/.hexagonal.platform.bootstrap.state.env.example"
}
