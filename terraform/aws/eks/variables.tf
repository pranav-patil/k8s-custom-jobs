variable "aws_region" {
  default = "us-east-1"
}

variable "stack_name" {
  type = string
  description = "Name of the AWS EKS cluster - will be used to name all created resources"
  default     = "emprovise-test"
}

variable "desired_capacity" {
  default = 2
}

variable "max_size" {
  default = 3
}

variable "min_size" {
  default = 1
}
