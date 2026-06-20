# Configuration for AWS ECS cluster, task definition, and service for the Express app.
# Main ecs cluster resource with container insights enabled for monitoring.
resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.standard_tags, {
    Name = "${local.name_prefix}-cluster"
  })
}

# CloudWatch log group for ECS tasks with a retention period of 14 days.
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.name_prefix}-app"
  retention_in_days = 14

  tags = local.standard_tags
}

# ECS task definition for the Express app, configured to run on Fargate with specified CPU and memory. It includes container definitions with environment variables and log configuration.
resource "aws_ecs_task_definition" "app" {
  family                   = "${local.name_prefix}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${local.name_prefix}-app"
      image     = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "PORT", value = tostring(var.container_port) }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = merge(local.standard_tags, { Name = "${local.name_prefix}-task" })
}

# ECS service definition for the Express app, configured to run on Fargate with a specified desired count. It includes load balancer configuration to forward traffic to the target group and network configuration for subnets and security groups.
resource "aws_ecs_service" "app" {
  name            = "${local.name_prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

# Load balancer configuration to forward traffic to the target group, specifying the container name and port.
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "${local.name_prefix}-app"
    container_port   = var.container_port
  }

# Network configuration for the ECS service, specifying the subnets, security groups, and assigning public IPs to the tasks.
  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs.id, aws_security_group.alb.id]
    assign_public_ip = true
  }

  depends_on = [aws_lb_listener.http]

  tags = merge(local.standard_tags, { Name = "${local.name_prefix}-service" })
}