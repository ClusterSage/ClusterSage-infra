data "azurerm_client_config" "current" {}

data "azurerm_container_registry" "global_shared" {
  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
}

locals {
  name_prefix = var.resource_name_prefix != null ? var.resource_name_prefix : lower("${var.project_name}-${var.environment}")
  tags = merge(var.tags, {
    Application = "ClusterSage"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
  origin_host_header     = var.frontdoor_origin_host_header != "" ? var.frontdoor_origin_host_header : var.frontdoor_origin_host_name
  frontdoor_origin_ready = var.frontdoor_origin_host_name != "" && var.frontdoor_origin_host_name != "replace-after-kgateway-load-balancer-is-created"
}

module "resource_group" {
  source   = "../../modules/resource-group"
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.tags
}

module "networking" {
  source                           = "../../modules/networking"
  name_prefix                      = local.name_prefix
  resource_group_name              = module.resource_group.name
  location                         = module.resource_group.location
  address_space                    = var.vnet_address_space
  aks_subnet_prefixes              = var.aks_subnet_prefix
  private_endpoint_subnet_prefixes = var.private_endpoint_subnet_prefix
  management_subnet_prefixes       = var.management_subnet_prefix
  tags                             = local.tags
}

module "managed_identity" {
  source              = "../../modules/managed-identity"
  name                = "id-${local.name_prefix}-workloads"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

module "monitoring" {
  source              = "../../modules/monitoring"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

module "aks" {
  source                          = "../../modules/aks"
  name                            = "aks-${local.name_prefix}"
  resource_group_name             = module.resource_group.name
  location                        = module.resource_group.location
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  local_account_disabled          = var.aks_local_account_disabled
  aks_subnet_id                   = module.networking.aks_subnet_id
  log_analytics_workspace_id      = module.monitoring.log_analytics_workspace_id
  node_count                      = var.aks_node_count
  auto_scaling_enabled            = var.aks_auto_scaling_enabled
  min_count                       = var.aks_min_count
  max_count                       = var.aks_max_count
  vm_size                         = var.aks_vm_size
  acr_id                          = data.azurerm_container_registry.global_shared.id
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges
  tags                            = local.tags
}

data "azurerm_kubernetes_cluster" "bootstrap" {
  count               = var.bootstrap_kgateway || var.bootstrap_argocd ? 1 : 0
  name                = module.aks.aks_name
  resource_group_name = module.resource_group.name

  depends_on = [module.aks]
}

module "service_bus" {
  source              = "../../modules/service-bus"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  queue_name          = "cluster-connected"
  tags                = local.tags
}

module "email" {
  source              = "../../modules/email"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  data_location       = var.communication_data_location
  sender_display_name = var.email_sender_display_name
  tags                = local.tags
}

module "storage" {
  source              = "../../modules/storage"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  container_name      = var.storage_container_name
  tags                = local.tags
}

module "key_vault" {
  source              = "../../modules/keyvault"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = local.tags
}

module "ai_foundry" {
  source                                = "../../modules/ai-foundry"
  enabled                               = var.ai_foundry_enabled
  name                                  = coalesce(var.ai_foundry_name, "oai-${local.name_prefix}")
  location                              = coalesce(var.ai_foundry_location, module.resource_group.location)
  resource_group_name                   = module.resource_group.name
  custom_subdomain_name                 = coalesce(var.ai_foundry_name, "oai-${local.name_prefix}")
  deployment_name                       = var.ai_model_deployment_name
  model_name                            = var.ai_model_name
  model_version                         = var.ai_model_version
  account_sku_name                      = "S0"
  deployment_sku_name                   = var.ai_model_sku_name
  deployment_capacity                   = var.ai_model_capacity
  backend_managed_identity_principal_id = module.managed_identity.principal_id
  key_vault_id                          = module.key_vault.id
  store_api_key_in_key_vault            = var.ai_store_api_key_in_key_vault
  key_vault_api_key_secret_name         = var.ai_key_vault_secret_name
  local_auth_enabled                    = var.ai_local_auth_enabled
  public_network_access_enabled         = var.ai_public_network_access_enabled
  tags                                  = local.tags
}

module "postgres" {
  count                  = var.create_database ? 1 : 0
  source                 = "../../modules/postgres"
  name_prefix            = local.name_prefix
  server_name            = var.postgres_server_name
  database_name          = var.postgres_database_name
  resource_group_name    = module.resource_group.name
  location               = module.resource_group.location
  administrator_login    = var.postgres_admin_login
  administrator_password = var.postgres_admin_password
  sku_name               = var.postgres_sku_name
  storage_mb             = var.postgres_storage_mb
  tags                   = local.tags
}

module "workload_identity" {
  source                    = "../../modules/workload-identity"
  name                      = "fic-${local.name_prefix}-${var.platform_service_account_name}"
  user_assigned_identity_id = module.managed_identity.id
  issuer                    = module.aks.aks_oidc_issuer_url
  namespace                 = var.platform_namespace
  service_account_name      = var.platform_service_account_name
}

resource "azurerm_role_assignment" "servicebus_sender" {
  scope                = module.service_bus.namespace_id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = module.managed_identity.principal_id
}

resource "azurerm_role_assignment" "servicebus_receiver" {
  scope                = module.service_bus.namespace_id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = module.managed_identity.principal_id
}

resource "azurerm_role_assignment" "communication_email_owner" {
  scope                = module.resource_group.id
  role_definition_name = "Communication and Email Service Owner"
  principal_id         = module.managed_identity.principal_id
}

resource "azurerm_role_assignment" "storage_blob_contributor" {
  scope                = module.storage.account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.managed_identity.principal_id
}

resource "azurerm_role_assignment" "keyvault_current_user" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = coalesce(var.key_vault_secrets_officer_principal_id, data.azurerm_client_config.current.object_id)
}

resource "azurerm_role_assignment" "keyvault_workload_reader" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.managed_identity.principal_id
}

module "kgateway_bootstrap" {
  source    = "../../modules/kgateway-bootstrap"
  enabled   = var.bootstrap_kgateway
  namespace = var.kgateway_namespace
}

module "argocd_bootstrap" {
  source              = "../../modules/argocd-bootstrap"
  enabled             = var.bootstrap_argocd
  namespace           = var.argocd_namespace
  server_service_type = var.argocd_server_service_type
}

module "frontdoor" {
  count               = var.create_frontdoor ? 1 : 0
  source              = "../../modules/frontdoor"
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  sku_name            = "Premium_AzureFrontDoor"
  tags                = local.tags

  origin_groups = local.frontdoor_origin_ready ? {
    prod = {
      health_probe_path = "/health"
    }
  } : {}

  origins = local.frontdoor_origin_ready ? {
    prod = {
      origin_group_name = "prod"
      host_name         = var.frontdoor_origin_host_name
      host_header       = local.origin_host_header
    }
  } : {}

  custom_domains = {
    for domain_name in var.frontdoor_custom_domain_names : domain_name => {}
  }

  routes = local.frontdoor_origin_ready ? {
    route-all = {
      origin_group_name   = "prod"
      origin_names        = ["prod"]
      patterns_to_match   = ["/*"]
      custom_domain_names = var.frontdoor_custom_domain_names
    }
  } : {}
}
