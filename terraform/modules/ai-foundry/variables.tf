variable "enabled" {
  type    = bool
  default = false
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "deployment_name" {
  type = string
}

variable "model_name" {
  type = string
}

variable "model_version" {
  type    = string
  default = ""
}

variable "account_sku_name" {
  type    = string
  default = "S0"
}

variable "deployment_sku_name" {
  type    = string
  default = "Standard"
}

variable "deployment_capacity" {
  type    = number
  default = 1
}

variable "backend_managed_identity_principal_id" {
  type    = string
  default = null
}

variable "backend_role_definition_name" {
  type    = string
  default = "Cognitive Services OpenAI User"
}

variable "key_vault_id" {
  type    = string
  default = null
}

variable "store_api_key_in_key_vault" {
  type    = bool
  default = false
}

variable "key_vault_api_key_secret_name" {
  type    = string
  default = "azure-openai-api-key"
}

variable "local_auth_enabled" {
  type    = bool
  default = true
}

variable "public_network_access_enabled" {
  type    = bool
  default = true
}

variable "custom_subdomain_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
