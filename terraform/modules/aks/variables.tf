variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "aks_subnet_id" { type = string }
variable "log_analytics_workspace_id" { type = string }
variable "node_count" {
  type = number

  validation {
    condition     = var.node_count >= 1
    error_message = "node_count must be at least 1."
  }
}
variable "vm_size" { type = string }
variable "tags" { type = map(string) }
variable "tenant_id" { type = string }

variable "auto_scaling_enabled" {
  type    = bool
  default = false

  validation {
    condition = (
      var.auto_scaling_enabled ?
      (var.min_count != null && var.max_count != null && var.max_count >= var.min_count) :
      true
    )
    error_message = "When auto_scaling_enabled is true, min_count and max_count must both be set and max_count must be greater than or equal to min_count."
  }
}

variable "min_count" {
  type    = number
  default = null

  validation {
    condition     = var.min_count == null || var.min_count >= 1
    error_message = "min_count must be null or at least 1."
  }
}

variable "max_count" {
  type    = number
  default = null

  validation {
    condition     = var.max_count == null || var.max_count >= 1
    error_message = "max_count must be null or at least 1."
  }
}

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
