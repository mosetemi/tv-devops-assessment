locals {
  name_prefix = "${var.project_name}-${var.environment}"

  standard_tags = {
    Project     = var.project_name
    Environment = var.environment
    managed_by  = "Terraform"
  }
}