variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "aks_subnet_id" { type = string }
variable "log_analytics_workspace_id" { type = string }
variable "node_count" { type = number }
variable "vm_size" { type = string }
variable "tags" { type = map(string) }
variable "tenant_id" { type = string }

variable "acr_id" {
  type    = string
  default = ""
}

variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "private_cluster_enabled" {
  type    = bool
  default = false
}

variable "local_account_disabled" {
  type    = bool
  default = false
}

variable "api_server_authorized_ip_ranges" {
  type    = list(string)
  default = []
}

variable "azure_rbac_enabled" {
  type    = bool
  default = true
}
