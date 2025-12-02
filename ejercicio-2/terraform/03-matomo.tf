# Deployment de Matomo
resource "kubernetes_deployment" "matomo" {
  metadata {
    name      = "matomo"       # Nombre del Deployment de Matomo
    namespace = kubernetes_namespace.matomo.metadata[0].name     # Namespace de Matomo
  }

  spec {
    replicas = 1   
    selector {
      match_labels = {
        app = "matomo"       # Selector para los pods de Matomo
      }
    }

    template {
      metadata {
        labels = {
          app = "matomo"     # Etiqueta para los pods de Matomo
        }
      }

      spec {
        container {
          name  = "matomo"     # Nombre del contenedor de Matomo
          image = "matomo:latest"  # Imagen de Matomo

          env {
            name  = "MATOMO_DATABASE_HOST"    # Variable de entorno para el host de la base de datos
            value = "mariadb"             # Nombre del servicio de MariaDB
          }

          env {
            name = "MATOMO_DATABASE_DBNAME"    # Variable de entorno para el nombre de la base de datos
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name  # Nombre del Secret para MariaDB
                key  = "database"        # Clave del secreto para el nombre de la base de datos
              }
            }
          }

          env {
            name = "MATOMO_DATABASE_USERNAME"   # Variable de entorno para el usuario de la base de datos
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name    # Nombre del Secret para MariaDB
                key  = "user"          # Clave del secreto para el usuario de la base de datos
              }
            }
          }

          env {
            name = "MATOMO_DATABASE_PASSWORD"  # Variable de entorno para la contraseña de la base de datos
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name   # Nombre del Secret para MariaDB
                key  = "password"    # Clave del secreto para la contraseña de la base de datos
              }
            }
          }

          port {
            container_port = 80  # Puerto en el que Matomo escucha dentro del contenedor
          }

          volume_mount {
            name       = "matomo-storage"   # Nombre del volumen para el almacenamiento de Matomo
            mount_path = "/var/www/html"    # Ruta dentro del contenedor para montar el volumen
          }
        }

        volume {
          name = "matomo-storage"     # Nombre del volumen para el almacenamiento de Matomo
          persistent_volume_claim {
            claim_name = "matomo-pvc"   # Nombre del PersistentVolumeClaim para Matomo
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_deployment.mariadb,    # Asegura que el Deployment de MariaDB se cree antes del Deployment de Matomo
    kubernetes_persistent_volume_claim.matomo   # Asegura que el PVC de Matomo se cree antes del Deployment de Matomo
  ]
}

# Service de Matomo con NodePort
resource "kubernetes_service" "matomo" {
  metadata {
    name      = "matomo"    # Nombre del Service de Matomo
    namespace = kubernetes_namespace.matomo.metadata[0].name   # Namespace de Matomo
  }

  spec {
    selector = {
      app = "matomo"   # Selector para los pods de Matomo
    }

    port {
      port        = 80     # Puerto del Service de Matomo dentro del clúster
      target_port = 80    # Puerto objetivo del contenedor de Matomo
      node_port   = 30082  # Puerto NodePort expuesto en los nodos del clúster
    }

    type = "NodePort"    # Tipo de Service
  }
}