variable "project_name" {
  type    = string
  default = "clustersage"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "acr_name" {
  type    = string
  default = "acrclustersagexxxxx"
}

variable "acr_anonymous_pull_enabled" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
