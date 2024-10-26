provider "google" {
  project = var.project_id
  region  = var.region
}

# Define the GKE Cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  # Number of nodes in the default pool
  initial_node_count = 1

  # Define the control plane settings
  remove_default_node_pool = true
  node_locations = [var.region]

  # Kubernetes version
  min_master_version = "1.27.2-gke.1200"

  # Network settings
  network    = "default"
  subnetwork = "default"
}

# Define a separate node pool (worker nodes) for the cluster
resource "google_container_node_pool" "primary_nodes" {
  cluster    = google_container_cluster.primary.name
  location   = var.region
  node_count = var.node_count

  # Node configuration (worker nodes)
  node_config {
    preemptible  = var.use_preemptible_nodes
    machine_type = var.node_machine_type

    # Enable auto-scaling for the node pool
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    metadata = {
      disable-legacy-endpoints = "true"
    }
    labels = {
      environment = var.environment
    }
    tags = ["gke-node", var.environment]

    # Set disk size for worker nodes
    disk_size_gb = 100
  }

  # Enable autoscaling for the node pool
  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }
}

# Output the cluster's credentials to use with kubectl
output "kubernetes_cluster_name" {
  value = google_container_cluster.primary.name
}

output "kubernetes_cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "kubernetes_cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

output "kubernetes_cluster_password" {
  value = google_container_cluster.primary.master_auth.0.password
}

output "kubernetes_cluster_username" {
  value = google_container_cluster.primary.master_auth.0.username
}

# VPC for the cluster (Optional - If you want to use a custom VPC)
resource "google_compute_network" "custom_vpc" {
  name = "gke-network"
  auto_create_subnetworks = false
}

# Define subnet for the cluster (Optional - If using a custom subnet)
resource "google_compute_subnetwork" "custom_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/16"
  network       = google_compute_network.custom_vpc.name
  region        = var.region
}

