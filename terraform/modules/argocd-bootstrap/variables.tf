variable "enabled" {
  type    = bool
  default = true
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "chart_version" {
  type    = string
  default = "7.8.28"
}

variable "server_service_type" {
  type    = string
  default = "ClusterIP"
}
