# Secret para credenciales de MariaDB
resource "kubernetes_secret" "mariadb" {
  metadata {
    name      = "mariadb-secret"        # Nombre del Secret para MariaDB
    namespace = kubernetes_namespace.matomo.metadata[0].name
  }

  data = {
    root-password = base64encode("rootpassword")       # Contraseña del usuario root de MariaDB
    database      = base64encode("matomo")       # Nombre de la base de datos de Matomo
    user          = base64encode("matomo")      # Usuario de la base de datos de Matomo
    password      = base64encode("matomopassword")    # Contraseña del usuario de la base de datos de Matomo
  }
}

# Deployment de MariaDB
resource "kubernetes_deployment" "mariadb" {
  metadata {
    name      = "mariadb"       # Nombre del Deployment de MariaDB
    namespace = kubernetes_namespace.matomo.metadata[0].name      # Namespace de Matomo
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mariadb"    # Selector para los pods de MariaDB
      }
    }

    template {
      metadata {
        labels = { 
          app = "mariadb"    # Etiqueta para los pods de MariaDB
        }
      }

      spec {
        container {
          name  = "mariadb"           # Nombre del contenedor de MariaDB
          image = "mariadb:10.11"    # Imagen de MariaDB

          env {
            name = "MYSQL_ROOT_PASSWORD"    # Variable de entorno para la contraseña del root
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name    
                key  = "root-password"    # Clave del secreto para la contraseña del root
              }
            }
          }

          env {
            name = "MYSQL_DATABASE"     # Variable de entorno para el nombre de la base de datos
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name      # Nombre del Secret para MariaDB
                key  = "database"          # Clave del secreto para el nombre de la base de datos
              }
            }
          }

          env {
            name = "MYSQL_USER"        # Variable de entorno para el usuario de la base de datos
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name    # Nombre del Secret para MariaDB
                key  = "user"          # Clave del secreto para el usuario de la base de datos
              }
            }
          }

          env {
            name = "MYSQL_PASSWORD"      # Variable de entorno para la contraseña del usuario de la base de datos
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mariadb.metadata[0].name     # Nombre del Secret para MariaDB
                key  = "password"      # Clave del secreto para la contraseña del usuario de la base de datos
              }
            }
          }

          port {
            container_port = 3306     # Puerto de MariaDB
          }

          volume_mount {
            name       = "mariadb-storage"  # Nombre del volumen para el almacenamiento de MariaDB
            mount_path = "/var/lib/mysql"  # Ruta dentro del contenedor para montar el volumen
          }
        }

        volume {
          name = "mariadb-storage"  # Nombre del volumen para el almacenamiento de MariaDB
          persistent_volume_claim {
            claim_name = "mariadb-pvc"  # Nombre del PersistentVolumeClaim para MariaDB
          }
        }
      }
    }
  }

  depends_on = [kubernetes_persistent_volume_claim.mariadb]   # Asegura que el PVC de MariaDB se cree antes del Deployment
}

# Service de MariaDB
resource "kubernetes_service" "mariadb" {
  metadata {
    name      = "mariadb"    # Nombre del Service de MariaDB
    namespace = kubernetes_namespace.matomo.metadata[0].name   # Namespace de Matomo
  }

  spec {
    selector = {
      app = "mariadb"     # Selector para los pods de MariaDB
    }

    port {
      port        = 3306     # Puerto del Service de MariaDB
      target_port = 3306     # Puerto objetivo del contenedor de MariaDB
    }

    type = "ClusterIP"      # Tipo de Service
  }
}