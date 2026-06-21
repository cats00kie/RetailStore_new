# ECS Task Definition for UI Service
resource "aws_ecs_task_definition" "ui" {
  family                   = "${var.app_name}-ui"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = var.container_images.ui.name
    image     = var.container_images.ui.image
    essential = true
    portMappings = [{
      containerPort = var.container_images.ui.port
      hostPort      = var.container_images.ui.port
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs["ui"].name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      {
        name  = "RETAIL_UI_ENDPOINTS_CATALOG"
        value = "http://catalog:8080"
      },
      {
        name  = "RETAIL_UI_ENDPOINTS_CARTS"
        value = "http://cart:8080"
      },
      {
        name  = "RETAIL_UI_ENDPOINTS_CHECKOUT"
        value = "http://checkout:8080"
      },
      {
        name  = "RETAIL_UI_ENDPOINTS_ORDERS"
        value = "http://orders:8080"
      }
    ]
  }])

  tags = {
    Name = "${var.app_name}-ui-task"
  }
}

# ECS Service for UI
resource "aws_ecs_service" "ui" {
  name            = "${var.app_name}-ui-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ui.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ui.arn
    container_name   = var.container_images.ui.name
    container_port   = var.container_images.ui.port
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy.ecs_task_execution_logs_policy
  ]

  tags = {
    Name = "${var.app_name}-ui-service"
  }
}

# ECS Task Definition for Admin Service
resource "aws_ecs_task_definition" "admin" {
  family                   = "${var.app_name}-admin"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = var.container_images.admin.name
    image     = var.container_images.admin.image
    essential = true
    portMappings = [{
      containerPort = var.container_images.admin.port
      hostPort      = var.container_images.admin.port
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs["admin"].name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      {
        name  = "ADMIN_USERNAME"
        value = "admin"
      },
      {
        name  = "ADMIN_JWT_SECRET"
        value = "change-me-in-production"
      }
    ]
  }])

  tags = {
    Name = "${var.app_name}-admin-task"
  }
}

# ECS Service for Admin
resource "aws_ecs_service" "admin" {
  name            = "${var.app_name}-admin-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.admin.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.admin.arn
    container_name   = var.container_images.admin.name
    container_port   = var.container_images.admin.port
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy.ecs_task_execution_logs_policy
  ]

  tags = {
    Name = "${var.app_name}-admin-service"
  }
}

# ECS Task Definition for Catalog Service
resource "aws_ecs_task_definition" "catalog" {
  family                   = "${var.app_name}-catalog"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = var.container_images.catalog.name
    image     = var.container_images.catalog.image
    essential = true
    portMappings = [{
      containerPort = var.container_images.catalog.port
      hostPort      = var.container_images.catalog.port
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs["catalog"].name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      {
        name  = "RETAIL_CATALOG_PERSISTENCE_PROVIDER"
        value = "postgres"
      },
      {
        name  = "RETAIL_CATALOG_PERSISTENCE_ENDPOINT"
        value = "${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}"
      },
      {
        name  = "DB_PASSWORD"
        value = var.db_password
      }
    ]
  }])

  tags = {
    Name = "${var.app_name}-catalog-task"
  }
}

# ECS Service for Catalog
resource "aws_ecs_service" "catalog" {
  name            = "${var.app_name}-catalog-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.catalog.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  depends_on = [
    aws_db_instance.postgres,
    aws_iam_role_policy.ecs_task_execution_logs_policy
  ]

  tags = {
    Name = "${var.app_name}-catalog-service"
  }
}

# ECS Task Definition for Cart Service
resource "aws_ecs_task_definition" "cart" {
  family                   = "${var.app_name}-cart"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = var.container_images.cart.name
    image     = var.container_images.cart.image
    essential = true
    portMappings = [{
      containerPort = var.container_images.cart.port
      hostPort      = var.container_images.cart.port
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs["cart"].name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      {
        name  = "RETAIL_CATALOG_PERSISTENCE_PROVIDER"
        value = "postgres"
      },
      {
        name  = "RETAIL_CATALOG_PERSISTENCE_ENDPOINT"
        value = "${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}"
      },
      {
        name  = "DB_PASSWORD"
        value = var.db_password
      }
    ]
  }])

  tags = {
    Name = "${var.app_name}-cart-task"
  }
}

# ECS Service for Cart
resource "aws_ecs_service" "cart" {
  name            = "${var.app_name}-cart-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.cart.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  depends_on = [
    aws_db_instance.postgres,
    aws_iam_role_policy.ecs_task_execution_logs_policy
  ]

  tags = {
    Name = "${var.app_name}-cart-service"
  }
}

# ECS Task Definition for Checkout Service
resource "aws_ecs_task_definition" "checkout" {
  family                   = "${var.app_name}-checkout"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = var.container_images.checkout.name
    image     = var.container_images.checkout.image
    essential = true
    portMappings = [{
      containerPort = var.container_images.checkout.port
      hostPort      = var.container_images.checkout.port
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs["checkout"].name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      {
        name  = "RETAIL_CHECKOUT_PERSISTENCE_PROVIDER"
        value = "redis"
      },
      {
        name  = "RETAIL_CHECKOUT_PERSISTENCE_REDIS_URL"
        value = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:${aws_elasticache_cluster.redis.port}"
      },
      {
        name  = "RETAIL_CHECKOUT_ENDPOINTS_ORDERS"
        value = "http://orders:8080"
      }
    ]
  }])

  tags = {
    Name = "${var.app_name}-checkout-task"
  }
}

# ECS Service for Checkout
resource "aws_ecs_service" "checkout" {
  name            = "${var.app_name}-checkout-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.checkout.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  depends_on = [
    aws_elasticache_cluster.redis,
    aws_iam_role_policy.ecs_task_execution_logs_policy
  ]

  tags = {
    Name = "${var.app_name}-checkout-service"
  }
}

# ECS Task Definition for Orders Service
resource "aws_ecs_task_definition" "orders" {
  family                   = "${var.app_name}-orders"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = var.container_images.orders.name
    image     = var.container_images.orders.image
    essential = true
    portMappings = [{
      containerPort = var.container_images.orders.port
      hostPort      = var.container_images.orders.port
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs["orders"].name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      {
        name  = "RETAIL_CATALOG_PERSISTENCE_PROVIDER"
        value = "postgres"
      },
      {
        name  = "RETAIL_CATALOG_PERSISTENCE_ENDPOINT"
        value = "${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}"
      },
      {
        name  = "DB_PASSWORD"
        value = var.db_password
      }
    ]
  }])

  tags = {
    Name = "${var.app_name}-orders-task"
  }
}

# ECS Service for Orders
resource "aws_ecs_service" "orders" {
  name            = "${var.app_name}-orders-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.orders.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  depends_on = [
    aws_db_instance.postgres,
    aws_iam_role_policy.ecs_task_execution_logs_policy
  ]

  tags = {
    Name = "${var.app_name}-orders-service"
  }
}
