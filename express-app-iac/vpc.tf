# VPC and network resources. The VPC is configured with DNS support and hostnames enabled, and the subnets are public with auto-assigned public IPs.
# An internet gateway is attached to the VPC, and a route table is created to allow outbound internet access from the public subnets.
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.standard_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}
# Subnets defined for the VPC: two public subnets in different availability zones for high availability
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.standard_tags, {
    Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
  })
}
# Security groups defined for both ECS tasks and the ALB to allow necessary traffic. 
resource "aws_security_group" "ecs" {
  name        = "${local.name_prefix}-ecs-sg"
  description = "Security group for ECS Fargate tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow inbound traffic to the container port"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.standard_tags, {
    Name = "${local.name_prefix}-ecs-sg"
  })
}

# Internet gateway for the VPC to allow outbound internet access from the public subnets.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.standard_tags, {
    Name = "${local.name_prefix}-igw"
  })
}

# Route table with a default route to the internet gateway and routing the public subnets for internet connectivity.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.standard_tags, {
    Name = "${local.name_prefix}-public-rt"
  })
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow inbound HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.standard_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}