# PersistentVolume para MariaDB
resource "kubernetes_persistent_volume" "mariadb" {
  metadata {
    name = "mariadb-pv"
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/tmp/mariadb-data"
        type = "DirectoryOrCreate"
      }
    }
    storage_class_name = "manual"
  }
}

# PersistentVolumeClaim para MariaDB
resource "kubernetes_persistent_volume_claim" "mariadb" {
  metadata {
    name      = "mariadb-pvc"
    namespace = kubernetes_namespace.matomo.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
    storage_class_name = "manual"
    volume_name        = kubernetes_persistent_volume.mariadb.metadata[0].name
  }
}

# PersistentVolume para Matomo
resource "kubernetes_persistent_volume" "matomo" {
  metadata {
    name = "matomo-pv"
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/tmp/matomo-data"
        type = "DirectoryOrCreate"
      }
    }
    storage_class_name = "manual"
  }
}

# PersistentVolumeClaim para Matomo
resource "kubernetes_persistent_volume_claim" "matomo" {
  metadata {
    name      = "matomo-pvc"
    namespace = kubernetes_namespace.matomo.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
    storage_class_name = "manual"
    volume_name        = kubernetes_persistent_volume.matomo.metadata[0].name
  }
}