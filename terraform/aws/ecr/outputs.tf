output "ecr_repository_urls" {
  value       = aws_ecr_repository.k8s_ecr_repo.repository_url
  description = "K8s repository URL that was created."
}
