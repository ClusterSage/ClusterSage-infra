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

variable "user_node_pool_enabled" {
  type    = bool
  default = false
}

variable "user_node_pool_name" {
  type    = string
  default = "user"
}

variable "user_node_count" {
  type    = number
  default = 1

  validation {
    condition     = var.user_node_count >= 1
    error_message = "user_node_count must be at least 1."
  }
}

variable "user_auto_scaling_enabled" {
  type    = bool
  default = false

  validation {
    condition = (
      var.user_auto_scaling_enabled ?
      (var.user_min_count != null && var.user_max_count != null && var.user_max_count >= var.user_min_count) :
      true
    )
    error_message = "When user_auto_scaling_enabled is true, user_min_count and user_max_count must both be set and user_max_count must be greater than or equal to user_min_count."
  }
}

variable "user_min_count" {
  type    = number
  default = null

  validation {
    condition     = var.user_min_count == null || var.user_min_count >= 1
    error_message = "user_min_count must be null or at least 1."
  }
}

variable "user_max_count" {
  type    = number
  default = null

  validation {
    condition     = var.user_max_count == null || var.user_max_count >= 1
    error_message = "user_max_count must be null or at least 1."
  }
}

variable "user_vm_size" {
  type    = string
  default = null
}

variable "user_node_labels" {
  type    = map(string)
  default = {}
}

variable "user_node_taints" {
  type    = list(string)
  default = []
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

variable "private_cluster_public_fqdn_enabled" {
  type    = bool
  default = false
}

variable "api_server_vnet_integration_enabled" {
  type    = bool
  default = false
}

variable "api_server_subnet_id" {
  type    = string
  default = null
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
