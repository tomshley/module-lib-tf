variable "platform_bootstrap_graph" {
  description = "graph root graph"
  type = any
}

variable "platform_bootstrap_graph_root_type" {
  description = "allowed root's"
  type = list(string)
  default = ["root",]
}

variable "state_identifier" {
  type = string
  description = "usually the project id"
}

variable "state_remote_host" {
  type = string
  description = "Gitlab remote state file address"
}

variable "state_username" {
  type = string
  description = "Gitlab username to query remote state"
}

variable "state_access_token" {
  type = string
  description = "GitLab access token to query remote state"
}

variable "root_path" {
  type = string
  default = "./"
}