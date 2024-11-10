terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Create an ECR Repository
resource "aws_ecr_repository" "k8s_ecr_repo" {
  name                 = "${var.stack_name}/admin-controller"
  image_tag_mutability = "MUTABLE"        # MUTABLE or IMMUTABLE; determines if tags can be overwritten
  image_scanning_configuration {
    scan_on_push = true                   # Enables image scanning on push
  }
}

resource "aws_ecr_lifecycle_policy" "k8s_ecr_repo_lifecycle_policy" {
  repository = aws_ecr_repository.k8s_ecr_repo.name

  policy = <<EOF
{
  "rules": [
    {
        "rulePriority": 1,
        "description": "Keep only ${var.max_image_count} tagged images, expire all others",
        "selection": {
            "tagStatus": "tagged",
            "tagPrefixList": ["${var.stack_name}-"],
            "countType": "imageCountMoreThan",
            "countNumber": ${var.max_image_count}
        },
        "action": {
            "type": "expire"
        }
    },
        {
        "rulePriority": 2   ,
        "description": "Expire images older than ${var.expiration_days} days",
        "selection": {
            "tagStatus": "any",
            "countType": "sinceImagePushed",
            "countUnit": "days",
            "countNumber": ${var.expiration_days}
        },
        "action": {
            "type": "expire"
        }
    }
  ]
}
EOF
}

resource "aws_ecr_repository_policy" "ecr" {
  repository = aws_ecr_repository.k8s_ecr_repo.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ECR Repo Policy",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${local.account_id}:root"
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}

# resource "aws_ecrpublic_repository" "public_repo" {
#   repository_name = "${var.stack_name}-k8s-ecr-repo"
#   tags = {
#     Environment = "Production"
#     Project     = "PublicContainerRepo"
#   }
# }
