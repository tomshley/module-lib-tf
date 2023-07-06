variable "platform_bootstrap_graph_directories" {
  description = "graph root directories"
  type        = any # todo - make this nicer, it's lame-ish
}

variable "breakglass_cred_host" {
  type = string
}

variable "breakglass_cred_user" {
  type = string
}

variable "breakglass_cred" {
  type = string
}