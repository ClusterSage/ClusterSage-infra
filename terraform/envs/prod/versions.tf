terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "kubernetes" {
  host                   = var.bootstrap_kgateway || var.bootstrap_argocd ? data.azurerm_kubernetes_cluster.bootstrap[0].kube_admin_config[0].host : "https://127.0.0.1"
  client_certificate     = var.bootstrap_kgateway || var.bootstrap_argocd ? base64decode(data.azurerm_kubernetes_cluster.bootstrap[0].kube_admin_config[0].client_certificate) : ""
  client_key             = var.bootstrap_kgateway || var.bootstrap_argocd ? base64decode(data.azurerm_kubernetes_cluster.bootstrap[0].kube_admin_config[0].client_key) : ""
  cluster_ca_certificate = var.bootstrap_kgateway || var.bootstrap_argocd ? base64decode(data.azurerm_kubernetes_cluster.bootstrap[0].kube_admin_config[0].cluster_ca_certificate) : ""
}

provider "helm" {
  kubernetes {
    host                   = var.bootstrap_kgateway || var.bootstrap_argocd ? data.azurerm_kubernetes_cluster.bootstrap[0].kube_admin_config[0].host : "https://127.0.0.1"
    client_certificate     = var.bootstrap_kgateway || var.bootstrap_argocd ? base64decode(data.azurerm_kubernetes_cluster.bootstrap[0].kube_admin_config[0].client_certificate) : ""
    client_key             = var.bootstrap_kgateway || var.bootstrap_argocd ? base64decode(data.azurerm_kubernetes_cluster.bootstrap[0].kube_admin_config[0].client_key) : ""
    cluster_ca_certificate = var.bootstrap_kgateway || var.bootstrap_argocd ? base64decode(data.azurerm_kubernetes_cluster.bootstrap[0].kube_admin_config[0].cluster_ca_certificate) : ""
  }
}
