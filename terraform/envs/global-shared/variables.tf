variable "project_name" {
  type    = string
  default = "clustersage"
}

# Global shared stays intentionally small so pipeline targeting is easy to verify across PR reruns.
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
  default = false
}

variable "tags" {
  type = map(string)
  default = {
    Owner = "platform"
  }
}
