variable "platform_bootstrap_graph" {
  description = "graph root graph"
  type = any
}

variable "platform_bootstrap_graph_root_type" {
  description = "allowed root's"
  type = list(string)
  default = ["root",]
}

variable "graph_root_filter" {
  description = "allowed tenants"
  type = list(string)
}

variable "ou_filter" {
  description = "allowed ou's"
  type = list(string)
  default = ["root_pam", "root_humans"]
}

variable "ou_nested_template" {
  description = "expandable ou's"
  type = list(string)
  default = ["root_pam",]
}

variable "primordial_ou_label" {
  description = "OU label for the primordial users"
  default = "primordial"
  type = string
}

variable "primordial_deprecated_ou_label" {
  description = "OU label for the primordial deprecated users"
  default = "deprecated"
  type = string
}

variable "primordial_staged_ou_label" {
  description = "OU label for the primordial staged users"
  default = "staged"
  type = string
}