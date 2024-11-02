variable "stack_name" {
  type    = string
  description = "Name of the GKE cluster - will be used to name all created resources"
  default     = "nova-test"
}

variable "region" {
  type    = string
  default = "East US"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "node_vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}
