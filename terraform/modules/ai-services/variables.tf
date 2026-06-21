variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }

variable "create_document_intelligence" {
  type    = bool
  default = false
}

variable "document_intelligence_name" {
  type    = string
  default = ""
}

variable "document_intelligence_sku_name" {
  type    = string
  default = "S0"
}

variable "create_openai" {
  type    = bool
  default = false
}

variable "openai_location" {
  type    = string
  default = null
}

variable "openai_name" {
  type    = string
  default = ""
}

variable "openai_sku_name" {
  type    = string
  default = "S0"
}

variable "openai_deployment_name" {
  type    = string
  default = ""
}

variable "openai_model_name" {
  type    = string
  default = ""
}

variable "openai_model_version" {
  type    = string
  default = ""
}

variable "openai_deployment_sku_name" {
  type    = string
  default = "Standard"
}

variable "openai_deployment_capacity" {
  type    = number
  default = 1
}
