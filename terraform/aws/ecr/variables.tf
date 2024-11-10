variable "aws_region" {
  default = "us-east-1"
}

variable "stack_name" {
  description = "Name of the AWS Kubernetes cluster - will be used to name all created resources"
  default     = "emprovise"
}

variable "max_image_count" {
  type        = number
  description = "The maximum number of tagged images to maintain in the repository without expiring"
  default     = 2
}

variable "expiration_days" {
  type        = number
  description = "The number of days used to determine when an image will expire once pushed"
  default     = 30
}
