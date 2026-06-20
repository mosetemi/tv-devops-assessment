# IAM Roles for ECS Task Execution and Task Role
# The iam policy document defines the trust relationship allowing ECS tasks to assume these roles
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# IAM Role for ECS Tasks - this is used to grant permissions to the tasks themselves (e.g., access to other AWS services)
resource "aws_iam_role" "ecs_task_role" {
  name               = "${local.name_prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(local.standard_tags, { Name = "${local.name_prefix}-ecs-task-role" })
}

# IAM Role for ECS Task Execution - this allows ECS to pull images and write logs
resource "aws_iam_role" "ecs_execution_role" {
  name               = "${local.name_prefix}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json

  tags = merge(local.standard_tags, { Name = "${local.name_prefix}-ecs-execution-role" })
}

# Attach the AmazonECSTaskExecutionRolePolicy to the execution role
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}