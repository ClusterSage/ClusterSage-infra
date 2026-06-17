output "namespace" { value = var.namespace }
output "server_service_name" { value = var.enabled ? data.kubernetes_service.argocd_server[0].metadata[0].name : null }
output "server_load_balancer_ip" {
  value = var.enabled ? try(data.kubernetes_service.argocd_server[0].status[0].load_balancer[0].ingress[0].ip, null) : null
}
output "server_load_balancer_hostname" {
  value = var.enabled ? try(data.kubernetes_service.argocd_server[0].status[0].load_balancer[0].ingress[0].hostname, null) : null
}
