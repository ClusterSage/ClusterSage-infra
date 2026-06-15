variable "enabled" {
  type    = bool
  default = true
}

variable "namespace" {
  type    = string
  default = "kgateway-system"
}

variable "chart_version" {
  type    = string
  default = "v2.3.0"
}

variable "gateway_api_crds_url" {
  type    = string
  default = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml"
}
