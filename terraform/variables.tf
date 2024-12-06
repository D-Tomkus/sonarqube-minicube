variable "namespace" {
  description = "Kubernetes namespace for SonarQube"
  type        = string
  default     = "sonarqube"
}

variable "postgresql_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}

variable "postgresql_user_password" {
  description = "PostgreSQL user password"
  type        = string
  sensitive   = true
}

variable "postgresql_replication_password" {
  description = "PostgreSQL replication password"
  type        = string
  sensitive   = true
}

variable "postgresql_version" {
  description = "PostgreSQL Helm chart version"
  type        = string
  default     = "12.5.8"
}

variable "sonarqube_version" {
  description = "SonarQube Helm chart version"
  type        = string
  default     = "9.9.1"
}

variable "values_dir" {
  description = "Directory containing values files"
  type        = string
  default     = "../values"
}