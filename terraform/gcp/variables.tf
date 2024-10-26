variable "project_id" {
  description = "The ID of the GCP project."
  type        = string
}

variable "region" {
  description = "The GCP region where the cluster will be created."
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster."
  type        = string
  default     = "my-gke-cluster"
}

variable "node_count" {
  description = "The number of worker nodes in the cluster."
  type        = number
  default     = 2
}

variable "node_machine_type" {
  description = "The machine type to use for worker nodes."
  type        = string
  default     = "n1-standard-1"
}

variable "use_preemptible_nodes" {
  description = "Use preemptible VMs for worker nodes to reduce cost."
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment label (e.g. 'dev', 'prod')."
  type        = string
  default     = "dev"
}
