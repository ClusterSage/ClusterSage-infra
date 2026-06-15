locals {
  project_compact = replace(replace(lower(var.project_name), "-", ""), " ", "")
  name_prefix     = lower(var.project_name)
  tags = merge(var.tags, {
    Application = "ClusterSage"
    Environment = "global-shared"
    ManagedBy   = "Terraform"
  })
}

module "resource_group" {
  source   = "../../modules/resource-group"
  name     = "rg-${local.name_prefix}-global"
  location = var.location
  tags     = local.tags
}

module "acr" {
  source                 = "../../modules/acr"
  name                   = var.acr_name
  resource_group_name    = module.resource_group.name
  location               = module.resource_group.location
  anonymous_pull_enabled = var.acr_anonymous_pull_enabled
  tags                   = local.tags
}
