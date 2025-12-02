# PersistentVolume para MariaDB
resource "kubernetes_persistent_volume" "mariadb" {       # Crea un PersistentVolume para MariaDB
  metadata {
    name = "mariadb-pv"    # Nombre del PersistentVolume para MariaDB
  }
  spec {
    capacity = {
      storage = "2Gi"   # Capacidad del volumen
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/tmp/mariadb-data"      # Ruta en el host para el almacenamiento de MariaDB
        type = "DirectoryOrCreate"      # Tipo de hostPath
      }
    }
    storage_class_name = "manual"      # Clase de almacenamiento
  }
}

# PersistentVolumeClaim para MariaDB
resource "kubernetes_persistent_volume_claim" "mariadb" {     # Crea un PersistentVolumeClaim para MariaDB
  metadata {
    name      = "mariadb-pvc"        # Nombre del PersistentVolumeClaim para MariaDB
    namespace = kubernetes_namespace.matomo.metadata[0].name  # Asocia el PVC al namespace de Matomo
  }
  spec {
    access_modes = ["ReadWriteOnce"]       # Modo de acceso al volumen
    resources {
      requests = {
        storage = "2Gi"             # Solicita 2Gi de almacenamiento
      }
    }
    storage_class_name = "manual"      # Clase de almacenamiento
    volume_name        = kubernetes_persistent_volume.mariadb.metadata[0].name # Asocia el PVC al PV de MariaDB
  }
}

# PersistentVolume para Matomo
resource "kubernetes_persistent_volume" "matomo" {        # Crea un PersistentVolume para Matomo, no es necesario pero me hacia dependencia circular
  metadata {
    name = "matomo-pv"        # Nombre del PersistentVolume para Matomo
  }
  spec {
    capacity = {
      storage = "2Gi"  # Capacidad del volumen
    }
    access_modes = ["ReadWriteOnce"]      # Modo de acceso al volumen
    persistent_volume_source {
      host_path {
        path = "/tmp/matomo-data"        # Ruta en el host para el almacenamiento de Matomo
        type = "DirectoryOrCreate"      # Tipo de hostPath
      } 
    }
    storage_class_name = "manual"      # Clase de almacenamiento
  }
}

# PersistentVolumeClaim para Matomo
resource "kubernetes_persistent_volume_claim" "matomo" {             # Crea un PersistentVolumeClaim para Matomo
  metadata {
    name      = "matomo-pvc"    # Nombre del PersistentVolumeClaim para Matomo
    namespace = kubernetes_namespace.matomo.metadata[0].name      # Asocia el PVC al namespace de Matomo
  }
  spec {
    access_modes = ["ReadWriteOnce"]    # Modo de acceso al volumen
    resources {
      requests = {
        storage = "2Gi"     # Solicita 2Gi de almacenamiento
      }
    }
    storage_class_name = "manual"    # Clase de almacenamiento
    volume_name        = kubernetes_persistent_volume.matomo.metadata[0].name     # Asocia el PVC al PV de Matomo
  }
}