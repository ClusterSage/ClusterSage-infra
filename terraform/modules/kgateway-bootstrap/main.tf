data "http" "gateway_api_standard_crds" {
  count = var.enabled ? 1 : 0
  url   = var.gateway_api_crds_url
}

locals {
  gateway_api_crd_raw_documents = var.enabled ? [
    for document in split("\n---", data.http.gateway_api_standard_crds[0].response_body) :
    document
    if length(regexall("(?m)^apiVersion:", document)) > 0
  ] : []
  gateway_api_crd_decoded_documents = [
    for document in local.gateway_api_crd_raw_documents :
    {
      for key, value in yamldecode(document) :
      key => value
      if key != "status"
    }
  ]
  gateway_api_crd_documents = {
    for manifest in local.gateway_api_crd_decoded_documents :
    "${manifest.kind}-${manifest.metadata.name}" => manifest
  }
}

resource "kubernetes_manifest" "gateway_api_crds" {
  for_each = local.gateway_api_crd_documents
  manifest = each.value

  field_manager {
    force_conflicts = true
  }
}

resource "time_sleep" "gateway_api_crds" {
  count           = var.enabled ? 1 : 0
  create_duration = "20s"
  depends_on      = [kubernetes_manifest.gateway_api_crds]
}

resource "helm_release" "kgateway_crds" {
  count            = var.enabled ? 1 : 0
  name             = "kgateway-crds"
  namespace        = var.namespace
  create_namespace = true
  chart            = "oci://cr.kgateway.dev/kgateway-dev/charts/kgateway-crds"
  version          = var.chart_version
  wait             = true
  timeout          = 600

  depends_on = [time_sleep.gateway_api_crds]
}

resource "time_sleep" "kgateway_crds" {
  count           = var.enabled ? 1 : 0
  create_duration = "20s"
  depends_on      = [helm_release.kgateway_crds]
}

resource "helm_release" "kgateway" {
  count     = var.enabled ? 1 : 0
  name      = "kgateway"
  namespace = var.namespace
  chart     = "oci://cr.kgateway.dev/kgateway-dev/charts/kgateway"
  version   = var.chart_version
  wait      = true
  timeout   = 600

  depends_on = [time_sleep.kgateway_crds]
}
