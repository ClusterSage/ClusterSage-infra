output "aks_id" { value = azurerm_kubernetes_cluster.main.id }
output "aks_name" { value = azurerm_kubernetes_cluster.main.name }
output "aks_oidc_issuer_url" { value = azurerm_kubernetes_cluster.main.oidc_issuer_url }
output "node_resource_group" { value = azurerm_kubernetes_cluster.main.node_resource_group }
output "user_node_pool_id" { value = var.user_node_pool_enabled ? azurerm_kubernetes_cluster_node_pool.user[0].id : null }
