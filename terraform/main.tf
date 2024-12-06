resource "kubernetes_namespace" "sonarqube" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "postgresql" {
  metadata {
    name      = "postgresql-secret"
    namespace = kubernetes_namespace.sonarqube.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "meta.helm.sh/release-name"      = "sonarqube"
      "meta.helm.sh/release-namespace" = "sonarqube"
    }
  }

  data = {
    "password"             = base64encode(var.postgresql_user_password)
    "postgresql-password"  = base64encode(var.postgresql_replication_password)
    "postgres-password"    = base64encode(var.postgresql_admin_password)
  }
}

resource "helm_release" "postgresql" {
  name       = "postgresql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = var.postgresql_version
  namespace  = kubernetes_namespace.sonarqube.metadata[0].name

  values = [
    file("${var.values_dir}/postgresql.yaml")
  ]

  depends_on = [kubernetes_secret.postgresql]
}

resource "time_sleep" "wait_for_postgresql" {
  depends_on = [helm_release.postgresql]

  create_duration = "30s"
}

resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  repository = "https://oteemo.github.io/charts"
  chart      = "sonarqube"
  version    = var.sonarqube_version
  namespace  = kubernetes_namespace.sonarqube.metadata[0].name

  values = [
    file("${var.values_dir}/sonarqube.yaml")
  ]

  depends_on = [time_sleep.wait_for_postgresql]
}