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

variable "openai_name" {
  type    = string
  default = ""
}

variable "openai_sku_name" {
  type    = string
  default = "S0"
}
