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
  private_dns_zones = var.enable_private_endpoints ? merge(
    var.enable_private_endpoint_key_vault ? {
      "privatelink.vaultcore.azure.net" = {
        name_prefix = "${local.name_prefix}-privatelink-vaultcore-azure-net"
      }
    } : {},
    var.enable_private_endpoint_postgres ? {
      "privatelink.postgres.database.azure.com" = {
        name_prefix = "${local.name_prefix}-privatelink-postgres-database-azure-com"
      }
    } : {},
    var.enable_private_endpoint_storage_blob ? {
      "privatelink.blob.core.windows.net" = {
        name_prefix = "${local.name_prefix}-privatelink-blob-core-windows-net"
      }
    } : {},
    var.enable_private_endpoint_ai_foundry ? {
      "privatelink.openai.azure.com" = {
        name_prefix = "${local.name_prefix}-privatelink-openai-azure-com"
      }
    } : {}
  ) : {}
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
  apiserver_subnet_prefixes        = var.api_server_subnet_prefix
  private_endpoint_subnet_prefixes = var.private_endpoint_subnet_prefix
  management_subnet_prefixes       = var.management_subnet_prefix
  tags                             = local.tags
}

module "private_dns" {
  source              = "../../modules/private-dns"
  resource_group_name = module.resource_group.name
  virtual_network_id  = module.networking.vnet_id
  zones               = local.private_dns_zones
  tags                = local.tags
}

module "managed_identity" {
  source              = "../../modules/managed-identity"
  name                = "id-${local.name_prefix}-workloads"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

module "aks_control_plane_identity" {
  source              = "../../modules/managed-identity"
  name                = "id-${local.name_prefix}-aks-control-plane"
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

resource "azurerm_monitor_workspace" "managed_prometheus" {
  count = var.aks_managed_observability_enabled ? 1 : 0

  name                          = coalesce(var.azure_monitor_workspace_name, "amw-${local.name_prefix}")
  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  public_network_access_enabled = var.azure_monitor_workspace_public_network_access_enabled
  tags = merge(local.tags, {
    Environment = "Prod"
    Service     = "Platform"
  })
}

resource "azurerm_dashboard_grafana" "managed" {
  count = var.aks_managed_observability_enabled ? 1 : 0

  name                          = coalesce(var.managed_grafana_name, "grafana-${var.environment}")
  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  grafana_major_version         = var.managed_grafana_major_version
  sku                           = var.managed_grafana_sku
  public_network_access_enabled = var.managed_grafana_public_network_access_enabled
  tags = merge(local.tags, {
    Environment = "Prod"
    Service     = "Platform"
  })

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.managed_prometheus[0].id
  }
}

resource "azurerm_role_assignment" "managed_grafana_monitoring_data_reader" {
  count = var.aks_managed_observability_enabled ? 1 : 0

  scope                = lower(azurerm_monitor_workspace.managed_prometheus[0].id)
  role_definition_name = "Monitoring Data Reader"
  principal_id         = azurerm_dashboard_grafana.managed[0].identity[0].principal_id
}

module "aks" {
  source                              = "../../modules/aks"
  name                                = "aks-${local.name_prefix}"
  resource_group_name                 = module.resource_group.name
  location                            = module.resource_group.location
  tenant_id                           = data.azurerm_client_config.current.tenant_id
  control_plane_identity_ids          = [module.aks_control_plane_identity.id]
  local_account_disabled              = var.aks_local_account_disabled
  private_cluster_enabled             = var.aks_private_cluster_enabled
  private_dns_zone_id                 = var.aks_private_dns_zone_id
  aks_subnet_id                       = module.networking.aks_subnet_id
  api_server_vnet_integration_enabled = var.aks_api_server_vnet_integration_enabled
  api_server_subnet_id                = module.networking.apiserver_subnet_id
  log_analytics_workspace_id          = module.monitoring.log_analytics_workspace_id
  node_count                          = var.aks_node_count
  auto_scaling_enabled                = var.aks_auto_scaling_enabled
  min_count                           = var.aks_min_count
  max_count                           = var.aks_max_count
  vm_size                             = var.aks_vm_size
  user_node_pool_enabled              = var.aks_user_node_pool_enabled
  user_node_count                     = var.aks_user_node_count
  user_auto_scaling_enabled           = var.aks_user_node_pool_enabled
  user_min_count                      = var.aks_user_min_count
  user_max_count                      = var.aks_user_max_count
  user_vm_size                        = var.aks_user_vm_size
  user_node_labels                    = { "workload" = "user" }
  acr_id                              = data.azurerm_container_registry.global_shared.id
  api_server_authorized_ip_ranges     = var.api_server_authorized_ip_ranges
  tags                                = local.tags
}

resource "azurerm_role_assignment" "aks_apiserver_subnet_network_contributor" {
  scope                = module.networking.apiserver_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks_control_plane_identity.principal_id
}

resource "azurerm_role_assignment" "aks_node_subnet_network_contributor" {
  scope                = module.networking.aks_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks_control_plane_identity.principal_id
}

data "azurerm_kubernetes_cluster" "bootstrap" {
  count               = var.bootstrap_kgateway || var.bootstrap_argocd ? 1 : 0
  name                = module.aks.aks_name
  resource_group_name = module.resource_group.name

  depends_on = [
    module.aks,
    azurerm_role_assignment.aks_apiserver_subnet_network_contributor,
  ]
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
  source                        = "../../modules/storage"
  name_prefix                   = local.name_prefix
  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  container_name                = var.storage_container_name
  public_network_access_enabled = var.storage_public_network_access_enabled
  tags                          = local.tags
}

module "key_vault" {
  source                        = "../../modules/keyvault"
  name_prefix                   = local.name_prefix
  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = var.key_vault_public_network_access_enabled
  tags                          = local.tags
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
  count                                 = var.create_database ? 1 : 0
  source                                = "../../modules/postgres"
  name_prefix                           = local.name_prefix
  server_name                           = var.postgres_server_name
  database_name                         = var.postgres_database_name
  resource_group_name                   = module.resource_group.name
  location                              = module.resource_group.location
  administrator_login                   = var.postgres_admin_login
  administrator_password                = var.postgres_admin_password
  sku_name                              = var.postgres_sku_name
  storage_mb                            = var.postgres_storage_mb
  create_replica                        = var.postgres_create_replica
  replica_name                          = var.postgres_replica_name
  replica_location                      = var.postgres_replica_location
  public_network_access_enabled         = var.postgres_public_network_access_enabled
  replica_public_network_access_enabled = true
  create_azure_services_firewall_rule   = var.postgres_create_azure_services_firewall_rule
  tags                                  = local.tags
}

module "key_vault_private_endpoint" {
  source                         = "../../modules/private-endpoint"
  enabled                        = var.enable_private_endpoints && var.enable_private_endpoint_key_vault
  name                           = "pep-${local.name_prefix}-kv"
  location                       = module.resource_group.location
  resource_group_name            = module.resource_group.name
  subnet_id                      = module.networking.private_endpoint_subnet_id
  private_connection_resource_id = module.key_vault.id
  subresource_names              = ["vault"]
  private_dns_zone_ids           = [module.private_dns.ids["privatelink.vaultcore.azure.net"]]
  tags                           = local.tags
}

module "postgres_private_endpoint" {
  source                         = "../../modules/private-endpoint"
  enabled                        = var.enable_private_endpoints && var.enable_private_endpoint_postgres && var.create_database
  name                           = "pep-${local.name_prefix}-postgres"
  location                       = module.resource_group.location
  resource_group_name            = module.resource_group.name
  subnet_id                      = module.networking.private_endpoint_subnet_id
  private_connection_resource_id = module.postgres[0].id
  subresource_names              = ["postgresqlServer"]
  private_dns_zone_ids           = [module.private_dns.ids["privatelink.postgres.database.azure.com"]]
  tags                           = local.tags
}

module "storage_blob_private_endpoint" {
  source                         = "../../modules/private-endpoint"
  enabled                        = var.enable_private_endpoints && var.enable_private_endpoint_storage_blob
  name                           = "pep-${local.name_prefix}-blob"
  location                       = module.resource_group.location
  resource_group_name            = module.resource_group.name
  subnet_id                      = module.networking.private_endpoint_subnet_id
  private_connection_resource_id = module.storage.account_id
  subresource_names              = ["blob"]
  private_dns_zone_ids           = [module.private_dns.ids["privatelink.blob.core.windows.net"]]
  tags                           = local.tags
}

module "ai_foundry_private_endpoint" {
  source                         = "../../modules/private-endpoint"
  enabled                        = var.enable_private_endpoints && var.enable_private_endpoint_ai_foundry && var.ai_foundry_enabled
  name                           = "pep-${local.name_prefix}-openai"
  location                       = module.resource_group.location
  resource_group_name            = module.resource_group.name
  subnet_id                      = module.networking.private_endpoint_subnet_id
  private_connection_resource_id = module.ai_foundry.id
  subresource_names              = ["account"]
  private_dns_zone_ids           = [module.private_dns.ids["privatelink.openai.azure.com"]]
  tags                           = local.tags
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

module "jumpbox" {
  source              = "../../modules/jumpbox"
  enabled             = var.jumpbox_enabled
  name_prefix         = local.name_prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.networking.management_subnet_id
  admin_username      = var.jumpbox_admin_username
  ssh_public_key      = var.jumpbox_ssh_public_key
  vm_size             = var.jumpbox_vm_size
  allowed_ssh_cidrs   = var.jumpbox_allowed_ssh_cidrs
  tags                = local.tags
}

module "jump_access" {
  source                         = "../../modules/jump-access"
  enabled                        = var.jump_access_enabled
  resource_group_name            = var.jump_access_resource_group_name
  location                       = var.jump_access_location
  vnet_name                      = var.jump_access_vnet_name
  vnet_address_space             = var.jump_access_vnet_address_space
  subnet_name                    = var.jump_access_subnet_name
  subnet_prefixes                = var.jump_access_subnet_prefixes
  prod_vnet_id                   = module.networking.vnet_id
  prod_vnet_name                 = "vnet-${local.name_prefix}"
  prod_resource_group_name       = module.resource_group.name
  prod_to_jump_peering_name      = var.jump_access_prod_to_jump_peering_name
  jump_to_prod_peering_name      = var.jump_access_jump_to_prod_peering_name
  vm_name                        = var.jump_access_vm_name
  vm_admin_username              = var.jump_access_vm_admin_username
  vm_size                        = var.jump_access_vm_size
  vm_public_ip_name              = var.jump_access_vm_public_ip_name
  vm_nic_name                    = var.jump_access_vm_nic_name
  vm_nsg_name                    = var.jump_access_vm_nsg_name
  vm_nsg_allowed_source_prefixes = var.jump_access_vm_nsg_allowed_source_prefixes
  bastion_name                   = var.jump_access_bastion_name
  vm_os_disk_name                = var.jump_access_vm_os_disk_name
  tags = merge(local.tags, {
    Environment = "Prod"
    Service     = "Platform"
  }, var.jump_access_tags)
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
