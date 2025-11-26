terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "kind-kind"
}

# Namespace
resource "kubernetes_namespace" "matomo" {
  metadata {
    name = "matomo"
  }
}