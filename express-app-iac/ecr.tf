# Configuration for AWS ECR repository and lifecycle policy for the Express app.
# This file defines where the Docker images will be stored, along with a lifecycle policy to manage old images.

# Configured to allow mutable tags and to force delete when the repository is removed.
resource "aws_ecr_repository" "app" {
  name                 = "${local.name_prefix}-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

# Enable image scanning on push to ensure vulnerabilities are identified in the container images
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.standard_tags, {
    Name = "${local.name_prefix}-repo"
  })
}

# The lifecycle policy with rules to expire untagged images older than 30 days and to keep only the last 10 tagged images.
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 30 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only the last 10 tagged images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}