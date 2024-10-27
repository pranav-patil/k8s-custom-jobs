# Output the cluster endpoint and kubeconfig
output "gke_cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "kubernetes_cluster_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

output "kubeconfig" {
  value = <<EOF
  provider "kubernetes" {
    host                   = google_container_cluster.gke_cluster.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
  }
EOF
}

