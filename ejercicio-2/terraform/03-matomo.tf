# Deployment de Matomo
resource "kubernetes_deployment" "matomo" {
  metadata {
    name      = "matomo"
    namespace = kubernetes_namespace.matomo.metadata[0].name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "matomo"
      }
    }

    template {
      metadata {
        labels = {
          app = "matomo"
        }
      }

      spec {
        container {
          name  = "matomo"
          image = "matomo:latest"

          env {
            name  = "MATOMO_DATABASE_HOST"
            value = "mariadb"
          }

          env {
            name = "MATOMO_DATABASE_DBNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name
                key  = "database"
              }
            }
          }

          env {
            name = "MATOMO_DATABASE_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name
                key  = "user"
              }
            }
          }

          env {
            name = "MATOMO_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name
                key  = "password"
              }
            }
          }

          port {
            container_port = 80
          }

          volume_mount {
            name       = "matomo-storage"
            mount_path = "/var/www/html"
          }
        }

        volume {
          name = "matomo-storage"
          persistent_volume_claim {
            claim_name = "matomo-pvc"
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment.mariadb,
    kubernetes_persistent_volume_claim.matomo
  ]
}

# Service de Matomo con NodePort
resource "kubernetes_service" "matomo" {
  metadata {
    name      = "matomo"
    namespace = kubernetes_namespace.matomo.metadata[0].name
  }

  spec {
    selector = {
      app = "matomo"
    }

    port {
      port        = 80
      target_port = 80
      node_port   = 30082
    }

    type = "NodePort"
  }
}