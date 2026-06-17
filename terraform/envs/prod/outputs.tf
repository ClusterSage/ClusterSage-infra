output "resource_group_name" { value = module.resource_group.name }
output "aks_name" { value = module.aks.aks_name }
output "acr_login_server" { value = data.terraform_remote_state.global_shared.outputs.acr_login_server }
output "vnet_id" { value = module.networking.vnet_id }
output "aks_subnet_id" { value = module.networking.aks_subnet_id }
output "frontdoor_origin_host_name" { value = var.frontdoor_origin_host_name }
output "frontdoor_origin_host_header" { value = local.origin_host_header }
output "frontdoor_endpoint_hostname" { value = var.create_frontdoor && length(module.frontdoor) > 0 ? module.frontdoor[0].endpoint_hostname : null }
output "service_bus_namespace" { value = module.service_bus.namespace_name }
output "service_bus_queue_name" { value = module.service_bus.queue_name }
output "storage_account_name" { value = module.storage.account_name }
output "storage_container_name" { value = module.storage.container_name }
output "storage_connection_string" {
  value     = module.storage.primary_connection_string
  sensitive = true
}
output "managed_identity_client_id" { value = module.managed_identity.client_id }
output "communication_email_endpoint" { value = module.email.communication_service_endpoint }
output "communication_email_sender_address" { value = module.email.sender_address }
output "key_vault_uri" { value = module.key_vault.vault_uri }
output "application_insights_connection_string" {
  value     = module.monitoring.application_insights_connection_string
  sensitive = true
}
output "postgres_fqdn" { value = var.create_database ? module.postgres[0].fqdn : null }
output "kgateway_namespace" { value = var.kgateway_namespace }
output "argocd_namespace" { value = var.argocd_namespace }
output "argocd_server_service_type" { value = var.argocd_server_service_type }
output "argocd_server_service_name" { value = var.bootstrap_argocd ? module.argocd_bootstrap.server_service_name : null }
output "argocd_server_load_balancer_ip" { value = var.bootstrap_argocd ? module.argocd_bootstrap.server_load_balancer_ip : null }
output "argocd_server_load_balancer_hostname" { value = var.bootstrap_argocd ? module.argocd_bootstrap.server_load_balancer_hostname : null }
output "platform_namespace" { value = var.platform_namespace }
