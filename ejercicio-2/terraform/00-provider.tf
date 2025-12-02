terraform {
  required_providers {
    kubernetes = {                            # Configura el proveedor de Kubernetes
      source  = "hashicorp/kubernetes"  
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"        # Ruta al archivo de configuración de kubeconfig
  config_context = "kind-kind"
}

# Namespace
resource "kubernetes_namespace" "matomo" {       # Crea un namespace para Matomo
  metadata {
    name = "matomo"
  }
}