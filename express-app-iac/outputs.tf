output "ecr_repository_url" {
  description = "ECR repository URL to push built images to"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "vpc_id" {
  value = aws_vpc.main.id
}