data "aws_iam_role" "labrole" {
  name = "LabRole"
}

data "aws_caller_identity" "current" {}

module "networking" {
  source             = "../../modules/networking"
  vpc_name           = var.vpc_name
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnet_cidr_blocks
  private_subnets    = var.private_subnet_cidr_blocks
  availability_zones = var.azs
  environment        = var.environment
}

module "cluster" {
  source       = "../../modules/ecs"
  cluster_name = var.cluster_name
  environment  = var.environment
}

module "ecr" {
  source      = "../../modules/ecr"
  environment = var.environment
  services    = ["catalog", "cart", "orders", "checkout", "ui", "admin"]
}

module "ui" {
  source             = "../../modules/ecs_service"
  app_name           = "retail-ui-${var.environment}"
  environment        = var.environment
  cluster_id         = module.cluster.cluster_id
  vpc_id             = module.networking.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  image_url          = "${module.ecr.repository_urls["ui"]}:latest"
  execution_role_arn = data.aws_iam_role.labrole.arn
  container_port     = 8080
  cpu                = var.app_cpu
  memory             = var.app_memory
  desired_count      = var.app_desired_count
  aws_region         = var.aws_region
  create_alb         = true
  container_environment = [
    {
      name  = "RETAIL_UI_ENDPOINTS_CATALOG"
      value = "http://${module.catalog.alb_dns_name}"
    },
    {
      name  = "RETAIL_UI_ENDPOINTS_CARTS"
      value = "http://${module.cart.alb_dns_name}"
    },
    {
      name  = "RETAIL_UI_ENDPOINTS_CHECKOUT"
      value = "http://${module.checkout.alb_dns_name}"
    },
    {
      name  = "RETAIL_UI_ENDPOINTS_ORDERS"
      value = "http://${module.orders.alb_dns_name}"
    }
  ]
}

module "catalog" {
  source             = "../../modules/ecs_service"
  app_name           = "retail-catalog-${var.environment}"
  environment        = var.environment
  cluster_id         = module.cluster.cluster_id
  vpc_id             = module.networking.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  image_url          = "${module.ecr.repository_urls["catalog"]}:latest"
  execution_role_arn = data.aws_iam_role.labrole.arn
  container_port     = 8080
  cpu                = var.app_cpu
  memory             = var.app_memory
  desired_count      = var.app_desired_count
  aws_region         = var.aws_region
  create_alb         = true
  container_environment = [
  {
    name  = "RETAIL_CATALOG_PERSISTENCE_PROVIDER"
    value = "postgres"
  },
  {
    name  = "RETAIL_CATALOG_PERSISTENCE_ENDPOINT"
    value = "${module.catalog_db.endpoint}:5432"
  },
  {
    name  = "RETAIL_CATALOG_PERSISTENCE_DB_NAME"
    value = "catalogdb"
  },
  {
    name  = "RETAIL_CATALOG_PERSISTENCE_USER"
    value = "catalog_user"
  },
  {
    name  = "RETAIL_CATALOG_PERSISTENCE_PASSWORD"
    value = var.catalog_db_password
  }
]
}

module "cart" {
  source             = "../../modules/ecs_service"
  app_name           = "retail-cart-${var.environment}"
  environment        = var.environment
  cluster_id         = module.cluster.cluster_id
  vpc_id             = module.networking.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  image_url          = "${module.ecr.repository_urls["cart"]}:latest"
  execution_role_arn = data.aws_iam_role.labrole.arn
  container_port     = 8080
  cpu                = var.app_cpu
  memory             = var.app_memory
  desired_count      = var.app_desired_count
  aws_region         = var.aws_region
  create_alb         = true
}

module "checkout" {
  source             = "../../modules/ecs_service"
  app_name           = "retail-checkout-${var.environment}"
  environment        = var.environment
  cluster_id         = module.cluster.cluster_id
  vpc_id             = module.networking.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  image_url          = "${module.ecr.repository_urls["checkout"]}:latest"
  execution_role_arn = data.aws_iam_role.labrole.arn
  container_port     = 8080
  cpu                = var.app_cpu
  memory             = var.app_memory
  desired_count      = var.app_desired_count
  aws_region         = var.aws_region
  create_alb         = true
}

module "orders" {
  source             = "../../modules/ecs_service"
  app_name           = "retail-orders-${var.environment}"
  environment        = var.environment
  cluster_id         = module.cluster.cluster_id
  vpc_id             = module.networking.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  image_url          = "${module.ecr.repository_urls["orders"]}:latest"
  execution_role_arn = data.aws_iam_role.labrole.arn
  container_port     = 8080
  cpu                = var.app_cpu
  memory             = var.app_memory
  desired_count      = var.app_desired_count
  aws_region         = var.aws_region
  create_alb         = true
  container_environment = [
    {
      name  = "RETAIL_ORDERS_PERSISTENCE_ENDPOINT"
      value = "${module.orders_db.endpoint}:5432"
    },
    {
      name  = "RETAIL_ORDERS_PERSISTENCE_NAME"
      value = "orders"
    },
    {
      name  = "RETAIL_ORDERS_PERSISTENCE_USERNAME"
      value = "retail_user"
    },
    {
      name  = "RETAIL_ORDERS_PERSISTENCE_PASSWORD"
      value = var.orders_db_password
    }
  ]
}

module "orders_db" {
  source = "../../modules/rds"

  name = "retail-orders-prod"

  vpc_id = module.networking.vpc_id

  private_subnet_ids = module.networking.private_subnet_ids

  ecs_security_group_id = module.orders.security_group_id

  password = var.orders_db_password
}

module "catalog_db" {
  source = "../../modules/rds"

  name = "retail-catalog-prod"

  vpc_id = module.networking.vpc_id

  private_subnet_ids = module.networking.private_subnet_ids

  ecs_security_group_id = module.catalog.security_group_id

  password = var.catalog_db_password
}

module "admin" {
  source             = "../../modules/ecs_service"
  app_name           = "retail-admin-${var.environment}"
  environment        = var.environment
  cluster_id         = module.cluster.cluster_id
  vpc_id             = module.networking.vpc_id
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  image_url          = "${module.ecr.repository_urls["admin"]}:latest"
  execution_role_arn = data.aws_iam_role.labrole.arn
  container_port     = 8080
  cpu                = 512
  memory             = 1024
  desired_count      = var.app_desired_count
  aws_region         = var.aws_region
  create_alb         = true
}

module "cloudwatch" {
  source                  = "../../modules/cloudwatch"
  app_name                = "retail-ui-${var.environment}"
  environment             = var.environment
  cluster_name            = var.cluster_name
  service_name            = module.ui.service_name
  alb_arn_suffix          = module.ui.alb_arn_suffix
  target_group_arn_suffix = module.ui.target_group_arn_suffix
  alarm_email             = var.alarm_email
  aws_region              = var.aws_region
}

module "lambda" {
  source        = "../../modules/lambda"
  app_name      = "retail"
  environment   = var.environment
  sns_topic_arn = module.cloudwatch.sns_topic_arn
  aws_region    = var.aws_region
  account_id    = data.aws_caller_identity.current.account_id
  log_group_names = [
    "/ecs/retail-ui-${var.environment}",
    "/ecs/retail-catalog-${var.environment}",
    "/ecs/retail-orders-${var.environment}",
    "/ecs/retail-cart-${var.environment}",
    "/ecs/retail-checkout-${var.environment}",
  ]
}