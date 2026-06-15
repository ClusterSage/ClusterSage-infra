resource "helm_release" "argocd" {
  count            = var.enabled ? 1 : 0
  name             = "argocd"
  namespace        = var.namespace
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  wait             = true
  timeout          = 900

  values = [yamlencode({
    server = {
      service = {
        type = var.server_service_type
      }
    }
  })]
}
