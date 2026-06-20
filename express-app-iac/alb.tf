# ALB and related resources for the Express app
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = merge(local.standard_tags, { Name = "${local.name_prefix}-alb" })
}

# Target group for the ECS service
resource "aws_lb_target_group" "app" {
  name     = "${local.name_prefix}-tg"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

# Health check configuration for the target group
  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200"
  }

# Ensures the target group is created before the ECS service tries to use it
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.standard_tags, { Name = "${local.name_prefix}-tg" })
}

# Listener for the ALB to forward traffic to the target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}