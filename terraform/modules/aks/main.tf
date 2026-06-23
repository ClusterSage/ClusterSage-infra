resource "azurerm_kubernetes_cluster" "main" {
  name                                = var.name
  resource_group_name                 = var.resource_group_name
  location                            = var.location
  dns_prefix                          = var.name
  oidc_issuer_enabled                 = true
  workload_identity_enabled           = true
  role_based_access_control_enabled   = true
  local_account_disabled              = var.local_account_disabled
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_cluster_enabled ? var.private_dns_zone_id : null
  private_cluster_public_fqdn_enabled = var.private_cluster_enabled ? var.private_cluster_public_fqdn_enabled : false
  sku_tier                            = var.sku_tier
  tags                                = var.tags

  dynamic "api_server_access_profile" {
    for_each = (
      length(var.api_server_authorized_ip_ranges) > 0 ||
      var.api_server_vnet_integration_enabled ||
      var.api_server_subnet_id != null
    ) ? [1] : []

    content {
      authorized_ip_ranges                = var.api_server_authorized_ip_ranges
      subnet_id                           = var.api_server_subnet_id
      virtual_network_integration_enabled = var.api_server_vnet_integration_enabled
    }
  }

  default_node_pool {
    name                 = "system"
    node_count           = var.auto_scaling_enabled ? null : var.node_count
    auto_scaling_enabled = var.auto_scaling_enabled
    min_count            = var.auto_scaling_enabled ? var.min_count : null
    max_count            = var.auto_scaling_enabled ? var.max_count : null
    vm_size              = var.vm_size
    vnet_subnet_id       = var.aks_subnet_id
  }

  identity {
    type         = length(var.control_plane_identity_ids) > 0 ? "UserAssigned" : "SystemAssigned"
    identity_ids = length(var.control_plane_identity_ids) > 0 ? var.control_plane_identity_ids : null
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = var.azure_rbac_enabled
    tenant_id          = var.tenant_id
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].upgrade_settings,
      identity,
      api_server_access_profile,
      private_cluster_enabled,
      private_dns_zone_id,
      private_cluster_public_fqdn_enabled,
      monitor_metrics,
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  count = var.user_node_pool_enabled ? 1 : 0

  name                  = var.user_node_pool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = coalesce(var.user_vm_size, var.vm_size)
  mode                  = "User"
  vnet_subnet_id        = var.aks_subnet_id
  node_count            = var.user_auto_scaling_enabled ? null : var.user_node_count
  auto_scaling_enabled  = var.user_auto_scaling_enabled
  min_count             = var.user_auto_scaling_enabled ? var.user_min_count : null
  max_count             = var.user_auto_scaling_enabled ? var.user_max_count : null
  node_labels           = var.user_node_labels
  node_taints           = length(var.user_node_taints) > 0 ? var.user_node_taints : null
  tags                  = var.tags

  lifecycle {
    ignore_changes = [
      upgrade_settings,
    ]
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  count                = var.acr_id == "" ? 0 : 1
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
