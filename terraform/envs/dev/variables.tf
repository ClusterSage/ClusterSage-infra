variable "project_name" {
  type    = string
  default = "clustersage"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "resource_name_prefix" {
  type    = string
  default = null
}

variable "state_resource_group_name" {
  type    = string
  default = "terraform-rg"
}

variable "state_storage_account_name" {
  type    = string
  default = "norahterraformstorageacc"
}

variable "state_container_name" {
  type    = string
  default = "terraformstate"
}

variable "acr_name" {
  type    = string
  default = "acrclustersage"
}

variable "acr_resource_group_name" {
  type    = string
  default = "rg-clustersage-global"
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.44.0.0/16"]
}
variable "aks_subnet_prefix" {
  type    = list(string)
  default = ["10.44.0.0/23"]
}

variable "private_endpoint_subnet_prefix" {
  type    = list(string)
  default = ["10.44.10.0/24"]
}

variable "enable_private_endpoints" {
  type    = bool
  default = true
}

variable "enable_private_endpoint_key_vault" {
  type    = bool
  default = true
}

variable "enable_private_endpoint_postgres" {
  type    = bool
  default = true
}

variable "enable_private_endpoint_storage_blob" {
  type    = bool
  default = true
}

variable "key_vault_public_network_access_enabled" {
  type    = bool
  default = false
}

variable "postgres_public_network_access_enabled" {
  type    = bool
  default = false
}

variable "postgres_create_azure_services_firewall_rule" {
  type    = bool
  default = false
}

variable "storage_public_network_access_enabled" {
  type    = bool
  default = false
}

variable "management_subnet_prefix" {
  type    = list(string)
  default = ["10.44.30.0/24"]
}

variable "aks_node_count" {
  type    = number
  default = 1
}

variable "aks_auto_scaling_enabled" {
  type    = bool
  default = true
}

variable "aks_min_count" {
  type    = number
  default = 1
}

variable "aks_max_count" {
  type    = number
  default = 2
}

variable "aks_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "aks_user_node_pool_enabled" {
  type    = bool
  default = true
}

variable "aks_user_node_count" {
  type    = number
  default = 1
}

variable "aks_user_min_count" {
  type    = number
  default = 1
}

variable "aks_user_max_count" {
  type    = number
  default = 2
}

variable "aks_user_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "aks_local_account_disabled" {
  type    = bool
  default = false
}

variable "api_server_authorized_ip_ranges" {
  type    = list(string)
  default = []
}

variable "postgres_admin_login" {
  type    = string
  default = "clustersageadmin"
}

variable "postgres_admin_password" {
  type      = string
  sensitive = true
}

variable "postgres_server_name" {
  type    = string
  default = "pg-clustersage-dev"
}

variable "postgres_database_name" {
  type    = string
  default = "clustersage"
}

variable "postgres_sku_name" {
  type    = string
  default = "GP_Standard_D2s_v3"
}

variable "postgres_storage_mb" {
  type    = number
  default = 32768
}

variable "postgres_create_replica" {
  type    = bool
  default = true
}

variable "postgres_replica_name" {
  type    = string
  default = "pg-clustersage-dev-dr"
}

variable "postgres_replica_location" {
  type    = string
  default = "South India"
}

variable "create_database" {
  type    = bool
  default = true
}

variable "storage_container_name" {
  type    = string
  default = "clustersage-data"
}

variable "communication_data_location" {
  type    = string
  default = "United States"
}

variable "email_sender_display_name" {
  type    = string
  default = "ClusterSage"
}

variable "key_vault_secrets_officer_principal_id" {
  type    = string
  default = null
}

variable "key_vault_name" {
  type    = string
  default = "kvclustersagedev01"
}

variable "platform_namespace" {
  type    = string
  default = "clustersage"
}

variable "platform_service_account_name" {
  type    = string
  default = "clustersage-workloads"
}

variable "kgateway_namespace" {
  type    = string
  default = "kgateway-system"
}

variable "bootstrap_kgateway" {
  type    = bool
  default = false
}

variable "bootstrap_argocd" {
  type    = bool
  default = false
}

variable "argocd_namespace" {
  type    = string
  default = "argocd"
}

variable "argocd_server_service_type" {
  type    = string
  default = "LoadBalancer"

  validation {
    condition     = contains(["ClusterIP", "LoadBalancer"], var.argocd_server_service_type)
    error_message = "argocd_server_service_type must be either ClusterIP or LoadBalancer."
  }
}

variable "frontdoor_origin_host_name" {
  type    = string
  default = ""
}

variable "frontdoor_origin_host_header" {
  type    = string
  default = "dev.nexaflow.site"
}

variable "create_frontdoor" {
  type    = bool
  default = false
}

variable "frontdoor_custom_domain_names" {
  type    = list(string)
  default = []
}

variable "tags" {
  type = map(string)
  default = {
    Owner = "platform"
  }
}
