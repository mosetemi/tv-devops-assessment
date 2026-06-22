# TurboVets DevOps Assessment

A complete full-stack application demonstrating DevOps best practices, featuring an Express.js TypeScript backend application with containerization and AWS infrastructure deployment.

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [Docker Deployment](#docker-deployment)
- [Infrastructure as Code](#infrastructure-as-code)
- [API Endpoints](#api-endpoints)
- [Available Scripts](#available-scripts)

## 🎯 Project Overview

This is a DevOps assessment project that demonstrates production-ready development practices:

- **Express.js TypeScript Application**: A modern REST API built with Express.js and TypeScript
- **Containerization**: Multi-stage Docker builds for optimized production images
- **Docker Compose**: Local development and production deployment configurations
- **Infrastructure as Code**: Terraform configuration for AWS deployment (ECS, ECR, ALB, VPC)
- **Production-Ready Architecture**: Health checks, environment-based configuration, and scalable deployment
- **Automated Cloud Deployment**: Fully automated infrastructure provisioning on AWS

## 📁 Project Structure

```
tv-devops-assessment/
├── express-app/                 # Express.js application
│   ├── src/
│   │   ├── app.ts              # Express app configuration
│   │   ├── server.ts           # Server entry point
│   │   └── routes/
│   │       └── index.ts        # Route definitions
│   ├── Dockerfile              # Multi-stage Docker build
│   ├── docker-compose.yaml     # Production Docker Compose config
│   ├── compose.debug.yaml      # Debug Docker Compose config
│   ├── package.json            # Node.js dependencies
│   ├── tsconfig.json           # TypeScript configuration
│   └── README.md               # App-specific documentation
│
└── express-app-iac/            # Infrastructure as Code (Terraform)
    ├── providers.tf            # AWS provider configuration
    ├── variables.tf            # Variable definitions
    ├── vpc.tf                  # VPC and networking
    ├── ecs.tf                  # ECS cluster and service
    ├── ecr.tf                  # ECR repository
    ├── alb.tf                  # Application Load Balancer
    ├── iam.tf                  # IAM roles and policies
    ├── locals.tf               # Local variables
    ├── backend.tf              # Terraform backend
    ├── outputs.tf              # Output values
    ├── terraform.tfvars        # Terraform variables file
    └── terraform.tfstate       # Terraform state (generated)
```

## 🛠 Tech Stack

### Application
- **Runtime**: Node.js LTS Alpine
- **Framework**: Express.js 5.1.0
- **Language**: TypeScript 5.8.3
- **Development**: ts-node-dev, TypeScript compiler
- **Environment Management**: dotenv

### DevOps & Infrastructure
- **Containerization**: Docker (Multi-stage builds)
- **Orchestration**: Docker Compose
- **Infrastructure**: AWS via Terraform
  - **ECS** (Elastic Container Service): Container orchestration
  - **ECR** (Elastic Container Registry): Container storage
  - **ALB** (Application Load Balancer): Traffic distribution
  - **VPC** (Virtual Private Cloud): Network isolation

## 📦 Prerequisites

### For Local Development
- **Node.js**: v18+
- **npm**: v9+
- **Docker**: v20+
- **Docker Compose**: v2+

### For AWS Deployment
- **Terraform**: v1.0+
- **AWS Account** with IAM permissions for:
  - ECS, ECR, ALB, VPC, IAM services
- **AWS CLI** (optional, for manual AWS interaction)

## 🚀 Installation

### Local Setup

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd tv-devops-assessment
   ```

2. **Navigate to the express-app directory**:
   ```bash
   cd express-app
   ```

3. **Install dependencies**:
   ```bash
   npm install
   ```

4. **Create a `.env` file** (optional):
   ```bash
   cp .env.example .env  # if .env.example exists
   ```

## 🏃 Running the Application

### Option 1: Development Mode (Local)

```bash
cd express-app
npm run dev
```

Server starts at `http://localhost:3000` with hot-reload enabled.

### Option 2: Production Build (Local)

```bash
cd express-app
npm run build    # Compile TypeScript
npm start        # Run compiled code
```

### Option 3: Docker Compose (Recommended for Testing)

```bash
cd express-app
docker-compose up
```

Application accessible at `http://localhost:3000`

### Option 4: Docker Compose Debug Mode

```bash
cd express-app
docker-compose -f compose.debug.yaml up
```

Enables debugging with `DEBUG=*` environment variable.

## 🐳 Docker Deployment

### Multi-Stage Build Strategy

The Dockerfile uses a two-stage build process for optimal efficiency:

**Stage 1 - Build**:
- Starts from `node:lts-alpine`
- Installs dependencies
- Compiles TypeScript to JavaScript
- Produces compiled code in `/dist`

**Stage 2 - Production**:
- Starts fresh from `node:lts-alpine`
- Copies only production dependencies
- Copies compiled code from build stage
- Sets `NODE_ENV=production`
- Runs as non-root `node` user
- Exposes port 3000

### Build and Run

```bash
cd express-app

# Build image
docker build -t express-ts-app:latest .

# Run container
docker run -p 3000:3000 express-ts-app:latest

# Run with custom port
docker run -p 8000:3000 -e PORT=3000 express-ts-app:latest
```

### Environment Variables

- `NODE_ENV`: Set to `production` in Docker image
- `PORT`: Application port (default: 3000)
- `DEBUG`: Enable debug logging (set to `*` for all modules)

## 🏗 Infrastructure as Code

### Terraform Overview

The `express-app-iac/` directory contains the complete AWS infrastructure definition. Terraform manages the deployment lifecycle of all cloud resources.

### Deployment Workflow

1. **Initialize Terraform** (first time only):
   ```bash
   cd express-app-iac
   terraform init
   ```

2. **Review planned changes**:
   ```bash
   terraform plan
   ```

3. **Apply configuration to AWS**:
   ```bash
   terraform apply
   ```

4. **View deployment outputs**:
   ```bash
   terraform output
   ```

5. **Destroy infrastructure** (if needed):
   ```bash
   terraform destroy
   ```

### AWS Resources Created

| Resource | Purpose |
|----------|---------|
| **VPC** | Custom network for application infrastructure |
| **Subnets** | Public and private subnets for resource segmentation |
| **Security Groups** | Firewall rules for network traffic |
| **ECR Repository** | Container image storage in AWS |
| **ECS Cluster** | Container orchestration platform |
| **ECS Service** | Manages running tasks and auto-scaling |
| **Task Definition** | Blueprint for running containers |
| **Application Load Balancer** | Distributes traffic across containers |
| **Target Group** | Links ALB to ECS service |
| **IAM Roles & Policies** | Secure access controls |

### Configuration (terraform.tfvars)

Edit `terraform.tfvars` to customize deployment:

```hcl
aws_account_id = "123456789012"    # Your AWS account ID
aws_region     = "us-east-1"       # AWS region (default: us-east-1)
project_name   = "express-ts-app"  # Project identifier
environment    = "prod"             # Environment: dev, staging, prod
```

## 📡 API Endpoints

### Base URL
```
http://localhost:3000
```

### Available Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Welcome message |
| GET | `/health` | Health check status |

### Response Examples

**GET /**
```
Hello from Express + TypeScript!
```

**GET /health**
```json
{
  "status": "ok"
}
```

## 📝 Available Scripts

### Express App (npm scripts)

```bash
# Development with hot-reload
npm run dev

# TypeScript compilation
npm run build

# Run compiled production code
npm start

# Test (placeholder)
npm test
```

### Docker Commands

```bash
# Build image
docker build -t express-ts-app .

# Run container
docker run -p 3000:3000 express-ts-app

# Docker Compose
docker-compose up                    # Start services
docker-compose down                  # Stop services
docker-compose logs -f               # View logs
docker-compose ps                    # List services
```

### Terraform Commands

```bash
terraform init          # Initialize Terraform
terraform plan          # Preview changes
terraform apply         # Deploy infrastructure
terraform destroy       # Remove infrastructure
terraform output        # Show output values
terraform state show    # Display current state
```

## 🔐 Security Considerations

### Application Security
- **Non-Root User**: Docker image runs as `node` user, not `root`
- **Multi-Stage Builds**: Reduces attack surface by excluding dev dependencies
- **12-Factor App**: Environment-based configuration for secrets management
- **Health Checks**: Built-in `/health` endpoint for monitoring

### Infrastructure Security
- **IAM Roles**: Least privilege principle for AWS service access
- **Security Groups**: Restricted network ingress/egress rules
- **Private Subnets**: Application runs in private network layer
- **Load Balancer**: Single point of entry with DDoS protection

## 📊 Monitoring & Logging

- **Health Endpoint**: `/health` returns service status
- **Docker Logs**: `docker logs <container-id>`
- **Docker Compose**: `docker-compose logs -f`
- **Debug Mode**: Set `DEBUG=*` environment variable
- **CloudWatch**: AWS logs available when deployed

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make changes and test locally
3. Build and verify: `npm run build`
4. Commit changes: `git commit -am 'Add my feature'`
5. Push to repository: `git push origin feature/my-feature`
6. Submit a pull request

## 📄 License

ISC License

## 📞 Support & Documentation

- **Application Details**: See [express-app/README.md](express-app/README.md)
- **Infrastructure**: Review [express-app-iac/](express-app-iac/) Terraform files
- **Troubleshooting**: Check Docker and Terraform output for error messages

### Quick Deployment

```bash
cd express-app-iac

# Edit terraform.tfvars and add your AWS account ID
terraform init    # Prepare for deployment
terraform plan    # Preview what will be created
terraform apply   # Actually create everything
```

After deployment completes, you'll get a web address where you can visit your app!

### Cleaning Up

If you want to delete everything from Amazon (useful for saving costs during testing):

```bash
terraform destroy  # Deletes all cloud resources
```

---

## Customizing Your Setup

### Application Settings

In the `express-app` folder, you can create a `.env` file to customize settings:

```env
PORT=3000              # What port the app listens on
NODE_ENV=production    # Whether it's for testing or real use
```

### Cloud Settings

In the `express-app-iac` folder, edit `terraform.tfvars` to customize your cloud setup:

```
aws_account_id = "123456789012"    # Your AWS account ID (required)
aws_region = "us-east-1"           # Where in the world to run it
environment = "dev"                # dev, staging, or prod
desired_count = 1                  # How many copies to run
```

### Common Customizations

- **Use more powerful server**: Change `task_cpu` or `task_memory`
- **Run multiple copies**: Change `desired_count` to more than 1
- **Use a different region**: Change `aws_region` to another Amazon datacenter

---

## What the Application Does

The application responds to two requests:

### 1. Main Endpoint
**URL**: `http://localhost:3000/`

Returns a simple greeting.

### 2. Health Check
**URL**: `http://localhost:3000/health`

Returns: `{"status":"ok"}`

This endpoint tells the cloud (or a monitoring system) that the application is running properly. The load balancer checks this every 30 seconds to make sure your app is healthy. If it stops responding, the cloud automatically restarts it.

### Testing Locally

```bash
# From another terminal
curl http://localhost:3000/
curl http://localhost:3000/health
```

---

## For Developers: Making Changes

### Quick Development Loop

```bash
cd express-app
npm run dev
# Edit files in src/
# App automatically restarts when you save
```

### Creating New Endpoints

Edit `src/routes/index.ts` to add new endpoints:

```javascript
router.get('/new-endpoint', (_req, res) => {
  res.json({ message: 'Your response here' });
});
```

### Building for Production

```bash
npm run build      # Compiles code
npm start          # Runs the compiled code
```

Then rebuild the Docker container to test:
```bash
docker build -t express-ts-app .
docker run -p 3000:3000 express-ts-app
```

---

## Deploying to Production (Simplified Steps)

### Step 1: Prepare the Container

```bash
cd express-app
docker build -t express-ts-app:v1.0.0 .
# This creates a sealed package of your application
```

### Step 2: Deploy to Cloud

```bash
cd ../express-app-iac

# Edit terraform.tfvars with your AWS details
terraform apply

# Wait for it to finish (5-10 minutes)
# You'll get a web address to access your app!
```

### Step 3: Test It

Visit the URL you received from terraform, or run:
```bash
curl https://your-app-url.com/
curl https://your-app-url.com/health
```

### Making Updates

```bash
# Make code changes
cd express-app
# ... edit files ...

# Rebuild and deploy
docker build -t express-ts-app:v1.0.1 .
cd ../express-app-iac
# Update terraform.tfvars with image_tag = "v1.0.1"
terraform apply
```

---

## Monitoring Your Application

### Checking Application Health

The health check endpoint (`/health`) runs automatically every 30 seconds. If it doesn't respond:
- The cloud waits 5 seconds and tries again
- If it fails 3 times in a row, the app is marked as "unhealthy"
- The cloud automatically stops and restarts it
- Traffic is rerouted to healthy instances

### Viewing Logs

Amazon keeps logs of everything your application does. To view them:

```bash
# View recent logs
aws logs tail /ecs/express-ts-app-dev-app --follow

# View logs from AWS Console:
# 1. Go to CloudWatch in AWS Console
# 2. Select "Log groups"
# 3. Find "/ecs/express-ts-app-dev-app"
```

Logs are kept for 14 days automatically.

### Monitoring Metrics

The cloud automatically tracks:
- How much CPU the app is using
- How much memory the app is using
- How many requests it's handling
- If tasks are crashing or restarting

View these in the AWS Console or use the AWS CLI.

---

## Common Problems and Fixes

### Can't Access the App

**Problem**: Getting "connection refused" or "cannot reach server"

**Solution**:
1. Make sure the app is running: `npm run dev` or `docker-compose up`
2. Check you're using the right port: `http://localhost:3000`
3. Check if port 3000 is already used by something else

### Deployment Fails

**Problem**: Terraform says it can't access AWS

**Solution**:
1. Verify your AWS account ID is correct in `terraform.tfvars`
2. Make sure your AWS credentials are configured
3. Check that your AWS account has permissions to create resources

### App Keeps Crashing

**Problem**: App starts then immediately stops

**Solution**:
1. Check the logs: `docker logs <container_id>`
2. Make sure Node.js is installed correctly
3. Make sure all dependencies are installed: `npm install`

### Port Already in Use

**Problem**: "Port 3000 is already in use"

**Solution**:
```bash
# Use a different port
PORT=8000 npm run dev

# Or find and stop the process using port 3000
lsof -i :3000
kill -9 <process_id>
```

### Can't Login to AWS

**Problem**: AWS CLI commands don't work

**Solution**:
```bash
# Check if AWS is configured
aws sts get-caller-identity

# If not, configure it
aws configure
# Enter your AWS access key and secret
```

### Need More Help?

Check:
1. AWS CloudWatch logs (in AWS Console under "Logs")
2. Docker logs with `docker logs`
3. Terraform output with `terraform show`

---

## Key Takeaways

This project shows:
2. **How to package an application** - Using Docker containers
3. **How to automate infrastructure** - Using Terraform and AWS
4. **How to monitor and maintain** - Using logs and health checks

It's a complete example of a modern, production-ready application setup.

---

**Last Updated**: 2026-06-20

For more information, check the individual folders or contact your development team.
