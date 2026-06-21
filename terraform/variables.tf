variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for resource deployment"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name (dev, staging, prod)"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "app_name" {
  type        = string
  default     = "retailstore"
  description = "Application name"
}

# VPC Configuration
variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for VPC"
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  description = "Availability zones for the application"
}

# ECS Configuration
variable "ecs_task_cpu" {
  type        = string
  default     = "256"
  description = "CPU units for ECS tasks (256, 512, 1024, 2048, 4096)"
}

variable "ecs_task_memory" {
  type        = string
  default     = "512"
  description = "Memory in MB for ECS tasks"
}

variable "ecs_desired_count" {
  type        = number
  default     = 1
  description = "Desired number of ECS tasks"
}

# Database Configuration
variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class for PostgreSQL"
}

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "Allocated storage in GB for PostgreSQL"
}

variable "db_username" {
  type        = string
  default     = "retailadmin"
  description = "PostgreSQL master username"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "PostgreSQL master password"
  sensitive   = true
}

# ElastiCache Configuration
variable "redis_node_type" {
  type        = string
  default     = "cache.t3.micro"
  description = "ElastiCache Redis node type"
}

variable "redis_num_cache_nodes" {
  type        = number
  default     = 1
  description = "Number of cache nodes for Redis"
}

# Load Balancer Configuration
variable "enable_https" {
  type        = bool
  default     = false
  description = "Enable HTTPS for ALB (requires ACM certificate)"
}

variable "acm_certificate_arn" {
  type        = string
  default     = ""
  description = "ARN of ACM certificate for HTTPS (required if enable_https is true)"
}

# Docker Image Configuration
variable "container_images" {
  type = map(object({
    name  = string
    image = string
    port  = number
  }))
  default = {
    ui = {
      name  = "ui"
      image = "nginx:latest" # Replace with your ECR image
      port  = 8080
    }
    catalog = {
      name  = "catalog"
      image = "your-account.dkr.ecr.us-east-1.amazonaws.com/catalog:latest"
      port  = 8080
    }
    cart = {
      name  = "cart"
      image = "your-account.dkr.ecr.us-east-1.amazonaws.com/cart:latest"
      port  = 8080
    }
    checkout = {
      name  = "checkout"
      image = "your-account.dkr.ecr.us-east-1.amazonaws.com/checkout:latest"
      port  = 8080
    }
    orders = {
      name  = "orders"
      image = "your-account.dkr.ecr.us-east-1.amazonaws.com/orders:latest"
      port  = 8080
    }
    admin = {
      name  = "admin"
      image = "your-account.dkr.ecr.us-east-1.amazonaws.com/admin:latest"
      port  = 8081
    }
  }
  description = "Docker images configuration for microservices"
}

variable "enable_monitoring" {
  type        = bool
  default     = true
  description = "Enable CloudWatch monitoring and alarms"
}

variable "log_retention_days" {
  type        = number
  default     = 7
  description = "CloudWatch log retention in days"
}
