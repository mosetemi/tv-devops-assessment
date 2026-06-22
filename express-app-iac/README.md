[![Build, Push, and Deploy](https://github.com/mosetemi/tv-devops-assessment/actions/workflows/deploy.yml/badge.svg)](https://github.com/mosetemi/tv-devops-assessment/actions/workflows/deploy.yml)

# express-app-iac

Infrastructure as Code for the `express-app` Express.js application, defined using Terraform and deployed to AWS.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites-for-portability)
- [Configuration](#configuration)
- [CI/CD pipeline on GitHub Actions](#CICD-pipeline-on-GitHub-Actions)
- [Destroying the Stack](#destroying-the-stack)
- [Variables Reference](#variables-reference)
- [Outputs Reference](#outputs-reference)
- [Design Decisions](#design-decisions)

---

## Architecture Overview

```
Internet
   │
   ▼
Application Load Balancer (port 80)
   │
   ▼
ECS Fargate Service (port 3000)
   │
   ├── Pulls image from ECR
   └── Sends logs to CloudWatch
```

### Resources created

| Resource | Description |
|---|---|
| VPC | Isolated network (`10.0.0.0/16`) with DNS enabled |
| Public Subnets (x2) | Across 2 Availability Zones for high availability |
| Internet Gateway | Allows outbound internet access from public subnets |
| Route Table | Routes all outbound traffic (`0.0.0.0/0`) to the IGW |
| Security Group (ALB) | Allows inbound HTTP:80 from the internet |
| Security Group (ECS) | Allows inbound port 3000 only from the ALB security group |
| ECR Repository | Stores Docker images with vulnerability scanning on push |
| ECR Lifecycle Policy | Retains only the last 10 images to control storage costs |
| IAM Execution Role | Allows ECS agent to pull images from ECR and write logs |
| IAM Task Role | Assumed by running application code (no permissions by default) |
| ECS Cluster | Logical grouping for the Fargate service, with Container Insights enabled |
| ECS Task Definition | Defines the container spec, CPU/memory, image, env vars, and log config |
| ECS Fargate Service | Keeps the desired number of tasks running, registers them with the ALB |
| ALB | Internet-facing Application Load Balancer |
| ALB Target Group | Routes traffic to Fargate task IPs, runs `/health` health checks |
| ALB Listener | Listens on port 80 and forwards to the target group |
| CloudWatch Log Group | Stores container logs for 14 days |

---

## Prerequisites For Portability:
1. Create IAM User
   a. Configure wiith these least priviledge permissions:
      - `AmazonECS_FullAccess`
      - `AmazonEC2ContainerRegistryFullAccess`
      - `AmazonEC2FullAccess`
      - `IAMFullAccess`
      - `CloudWatchLogsFullAccess`
      - `AmazonS3FullAccess` (for Terraform remote state)

2. Store these values into GitHub secrets and variables:
   Secret:
      - "AWS_ACCOUNT_ID" = AWS account ID
      - "AWS_ACCESS_KEY_ID" = IAM user Access Key ID
      - "AWS_SECRET_ACCESS_KEY" = IAM user Scret Access Key *(will also use later during AWS config so store until after)*
      - Generate an IaC repo token (PAT), label it "IAC_REPO_TOKEN"

   Variables:
      - AWS_REGION = *YOUR AWS REGION*
      - ECR_REPOSITORY = express-ts-app-dev-repo
      - ECS_CLUSTER = express-ts-app-dev-cluster
      - ECS_SERVICE = express-ts-app-dev-service

3. In local terminal, run AWS configure and enter appropriate credentials.

---

## Configuration

### Step 1 — Create a Terraform state S3 bucket

Terraform requires an S3 bucket to store its state file before it can manage any infrastructure. This is a **one-time manual step** — create the bucket in your AWS account before running `terraform init`:
   - Enter bucket name
   - Enable versioning
   - Ensure "block all public access" is checked
   - Create bucket

### Step 2 — Update `backend.tf`

Open `backend.tf` and replace `YOUR_BUCKET_NAME` with the name you gave your bucket:

```h
terraform {
  backend "s3" {
    bucket       = "YOUR_BUCKET_NAME"
    key          = "express-ts-app/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

### Step 3 — Initialize, plan, and apply
```bash
terraform init
terraform plan
terraform apply
```

Type `yes` when prompted. Provisioning takes approximately **3–5 minutes** — the ALB and ECS service take the longest to become active.

Once complete, Terraform prints the stack outputs:

```
alb_dns_name       = "your-alb-name.us-east-1.elb.amazonaws.com"
ecr_repository_url = "example.dkr.ecr.us-east-1.amazonaws.com/express-ts-app-dev-repo"
ecs_cluster_name   = "express-ts-app-dev-cluster"
ecs_service_name   = "express-ts-app-dev-service"
vpc_id             = "vpc-example"
```

### CI/CD pipeline on GitHub Actions

Before the ECS service can run successfully, at least one image must exist in ECR. After `terraform apply` completes, push an initial image:

Push GitHub Workflow for automatic integration and deployment

## Destroying the Stack

To tear down all AWS resources and stop incurring costs:

```bash
terraform destroy
```

Type `yes` when prompted.

> *Note* If the ECR repository contains images, destroy will fail with a `RepositoryNotEmptyException`. Either delete the images first via the AWS console, or temporarily add `force_delete = true` to the `aws_ecr_repository` resource in `ecr.tf` before running destroy.

> *Note* The S3 state bucket is **not** managed by Terraform and will not be destroyed by `terraform destroy`. Delete it manually via the AWS console or CLI if no longer needed.

---

## Variables Reference

All variables are declared in `variables.tf`. Feel free to override them in `terraform.tfvars`

---

## Design Decisions

### Principle of least privilege
Rather than giving IAM user full administrative access, **only the necessary roles** have been applied. One tradeoff however, is the S3FullAccess policy granted. In an production environment, the best practice is to create a custom policy for get and put Object rights; however, I opted in giving the user full S3 access for simplicity sake.

### Public subnets with `assign_public_ip = true`
Fargate tasks are placed in public subnets with public IPs to allow outbound connectivity to ECR (image pulls) and CloudWatch (logging) without requiring a NAT Gateway (~$32/month). Direct inbound access on port 3000 is blocked at the security group level — only the ALB's security group can reach the tasks. A production deployment would use private subnets + NAT Gateway for stricter network isolation.

### Two separate IAM roles
A dedicated **execution role** (used by the ECS agent to pull images and write logs) and **task role** (assumed by the running application code) are kept strictly separate. This ensures a compromised application process cannot leverage the execution role's ECR/logging permissions — a least-privilege boundary that's cheap to maintain and meaningful to have.

### ECR lifecycle policy
A lifecycle policy retains only the last 10 images, preventing unbounded storage growth from repeated CI/CD pushes over time.

### S3 native locking (`use_lockfile = true`)
Terraform 1.10+ supports S3-native state locking without DynamoDB, reducing the number of resources needed to bootstrap the remote backend.