locals {
  name_prefix = lower("${var.project_name}-nonprod")
  tags = merge(var.tags, {
    Application = "ClusterSage"
    Environment = "nonprod-shared"
    ManagedBy   = "Terraform"
  })
}

module "resource_group" {
  source   = "../../modules/resource-group"
  name     = "rg-${lower(var.project_name)}-nonprod-shared"
  location = var.location
  tags     = local.tags
}

data "terraform_remote_state" "dev" {
  count   = var.attach_dev_origin ? 1 : 0
  backend = "azurerm"
  config = {
    resource_group_name  = var.state_resource_group_name
    storage_account_name = var.state_storage_account_name
    container_name       = var.state_container_name
    key                  = "dev.tfstate"
    use_azuread_auth     = true
  }
}

data "terraform_remote_state" "staging" {
  count   = var.attach_staging_origin ? 1 : 0
  backend = "azurerm"
  config = {
    resource_group_name  = var.state_resource_group_name
    storage_account_name = var.state_storage_account_name
    container_name       = var.state_container_name
    key                  = "staging.tfstate"
    use_azuread_auth     = true
  }
}

locals {
  dev_origin_host_name = var.dev_origin_host_name_override != "" ? var.dev_origin_host_name_override : (
    var.attach_dev_origin ? try(data.terraform_remote_state.dev[0].outputs.frontdoor_origin_host_name, "") : ""
  )
  dev_origin_host_header = var.dev_origin_host_header_override != "" ? var.dev_origin_host_header_override : (
    var.attach_dev_origin ? try(data.terraform_remote_state.dev[0].outputs.frontdoor_origin_host_header, local.dev_origin_host_name) : local.dev_origin_host_name
  )
  staging_origin_host_name = var.staging_origin_host_name_override != "" ? var.staging_origin_host_name_override : (
    var.attach_staging_origin ? try(data.terraform_remote_state.staging[0].outputs.frontdoor_origin_host_name, "") : ""
  )
  staging_origin_host_header = var.staging_origin_host_header_override != "" ? var.staging_origin_host_header_override : (
    var.attach_staging_origin ? try(data.terraform_remote_state.staging[0].outputs.frontdoor_origin_host_header, local.staging_origin_host_name) : local.staging_origin_host_name
  )
  dev_origin_enabled   = local.dev_origin_host_name != ""
  stage_origin_enabled = local.staging_origin_host_name != ""

  nonprod_origins = merge(
    local.dev_origin_enabled ? {
      dev = {
        origin_group_name = "dev"
        host_name         = local.dev_origin_host_name
        host_header       = local.dev_origin_host_header
      }
    } : {},
    local.stage_origin_enabled ? {
      stage = {
        origin_group_name = "stage"
        host_name         = local.staging_origin_host_name
        host_header       = local.staging_origin_host_header
      }
    } : {}
  )

  custom_domain_names = distinct(concat(
    var.dev_custom_domain_name != "" ? [var.dev_custom_domain_name] : [],
    var.stage_custom_domain_name != "" ? [var.stage_custom_domain_name] : [],
    var.custom_domain_names
  ))
}

module "frontdoor" {
  source              = "../../modules/frontdoor"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  sku_name            = "Premium_AzureFrontDoor"
  tags                = local.tags

  origin_groups = {
    dev = {
      health_probe_path = "/health"
    }
    stage = {
      health_probe_path = "/health"
    }
  }

  origins = local.nonprod_origins

  custom_domains = {
    for domain_name in local.custom_domain_names : domain_name => {}
  }

  routes = merge(
    local.dev_origin_enabled ? {
      dev = {
        origin_group_name   = "dev"
        origin_names        = ["dev"]
        patterns_to_match   = ["/*"]
        custom_domain_names = var.dev_custom_domain_name != "" ? [var.dev_custom_domain_name] : []
      }
    } : {},
    local.stage_origin_enabled ? {
      stage = {
        origin_group_name   = "stage"
        origin_names        = ["stage"]
        patterns_to_match   = ["/*"]
        custom_domain_names = var.stage_custom_domain_name != "" ? [var.stage_custom_domain_name] : []
      }
    } : {}
  )
}

module "ai_services" {
  source                       = "../../modules/ai-services"
  resource_group_name          = module.resource_group.name
  location                     = module.resource_group.location
  create_document_intelligence = var.create_document_intelligence
  document_intelligence_name   = "di-${lower(var.project_name)}-nonprod"
  create_openai                = var.create_openai
  openai_location              = var.openai_location
  openai_name                  = "oai-${lower(var.project_name)}-nonprod"
  openai_deployment_name       = var.openai_deployment_name
  openai_model_name            = var.openai_model_name
  openai_model_version         = var.openai_model_version
  openai_deployment_sku_name   = var.openai_deployment_sku_name
  openai_deployment_capacity   = var.openai_deployment_capacity
  tags                         = local.tags
}
