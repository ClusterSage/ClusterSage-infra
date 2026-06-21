variable "project_name" {
  type    = string
  default = "clustersage"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "tags" {
  type    = map(string)
  default = {}
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

variable "attach_dev_origin" {
  type    = bool
  default = false
}

variable "attach_staging_origin" {
  type    = bool
  default = false
}

variable "dev_origin_host_name_override" {
  type    = string
  default = ""
}

variable "dev_origin_host_header_override" {
  type    = string
  default = ""
}

variable "staging_origin_host_name_override" {
  type    = string
  default = ""
}

variable "staging_origin_host_header_override" {
  type    = string
  default = ""
}

variable "custom_domain_names" {
  type    = list(string)
  default = []
}

variable "dev_custom_domain_name" {
  type    = string
  default = "dev.nexaflow.site"
}

variable "stage_custom_domain_name" {
  type    = string
  default = "stage.nexaflow.site"
}

variable "create_document_intelligence" {
  type    = bool
  default = false
}

variable "create_openai" {
  type    = bool
  default = false
}

variable "openai_location" {
  type    = string
  default = null
}

variable "openai_deployment_name" {
  type    = string
  default = "gpt-4.1-mini"
}

variable "openai_model_name" {
  type    = string
  default = "gpt-4.1-mini"
}

variable "openai_model_version" {
  type    = string
  default = "2025-04-14"
}

variable "openai_deployment_sku_name" {
  type    = string
  default = "Standard"
}

variable "openai_deployment_capacity" {
  type    = number
  default = 10
}
