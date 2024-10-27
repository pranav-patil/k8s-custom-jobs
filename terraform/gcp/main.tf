# Configure the Google Cloud provider
provider "google" {
  project = var.gce_project
  region  = var.gcp_region
}

# Define a GKE cluster
resource "google_container_cluster" "gke_cluster" {
  name     = "${var.stack_name}-gke-cluster"
  location = var.gcp_region

  # Define the number of initial nodes and node configuration
  initial_node_count = 1           # Master node (control plane)
  remove_default_node_pool = true  # Remove the default node pool
  deletion_protection = false       # Set deletion protection to false

  # Enable IP aliasing for VPC-native clusters
  ip_allocation_policy {}
}

# k8s node pool
resource "google_container_node_pool" "node_pool" {
  name       = "default-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.gke_cluster.name
  node_count = var.node_pool_node_count

  node_config {
    preemptible  = false
    machine_type = "n1-standard-2" # pricing: https://cloud.google.com/compute/vm-instance-pricing#n1_predefined
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#       # Grants Read Access to GCR to clusters
#       "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    labels = {
      type = "nfs"
    }
    tags = [var.stack_name]
  }

    autoscaling {
      min_node_count = 1
      max_node_count = 3
    }
}
