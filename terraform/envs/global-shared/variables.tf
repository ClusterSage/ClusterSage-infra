variable "project_name" {
  type    = string
  default = "clustersage"
}

variable "location" {
  type    = string
  default = "Central India"
}

variable "acr_name" {
  type    = string
  default = "acrclustersage"
}

variable "acr_anonymous_pull_enabled" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {
    Owner = "platform"
  }
}
