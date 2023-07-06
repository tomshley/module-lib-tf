variable "platform_bootstrap_graph" {
  description = "graph root graph"
  type = any
}

variable "platform_bootstrap_graph_root_type" {
  description = "allowed root's"
  type = list(string)
  default = ["root",]
}