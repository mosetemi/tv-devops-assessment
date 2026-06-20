# Variables
variable "aws_account_id" {
  description = "The AWS account ID to deploy resources into. This is used to restrict the provider to a specific account."
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project. This will be used to name resources."
  type        = string
  default     = "express-ts-app"
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "container_port" {
  description = "The port on which the container will listen on."
  type        = number
  default     = 3000
}

variable "task_cpu" {
  description = "The amount of CPU units to allocate for the ECS task."
  type        = string
  default     = 256
}

variable "task_memory" {
  description = "The amount of memory (in MiB) to allocate for the Fargate task."
  type        = string
  default     = 512
}

variable "desired_count" {
  description = "The desired number of ECS tasks to run."
  type        = number
  default     = 1
}

variable "image_tag" {
  description = "Docker image tag to deploy."
  type        = string
  default     = "latest"
}