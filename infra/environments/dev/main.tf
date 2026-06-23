data "aws_iam_role" "labrole" {
  name = "LabRole"
}

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

resource "aws_service_discovery_private_dns_namespace" "retail" {
  name = "retail-${var.environment}.local"
  vpc  = module.networking.vpc_id
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
  environment_variables = {
    RETAIL_UI_ENDPOINTS_CATALOG  = "http://catalog.retail-${var.environment}.local:8080"
    RETAIL_UI_ENDPOINTS_CARTS    = "http://carts.retail-${var.environment}.local:8080"
    RETAIL_UI_ENDPOINTS_CHECKOUT = "http://checkout.retail-${var.environment}.local:8080"
    RETAIL_UI_ENDPOINTS_ORDERS   = "http://orders.retail-${var.environment}.local:8080"
  }
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
  create_alb         = false
  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.retail.id
  service_discovery_name         = "catalog"
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
  create_alb         = false
  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.retail.id
  service_discovery_name         = "carts"
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
  create_alb         = false
  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.retail.id
  service_discovery_name         = "checkout"
  environment_variables = {
    RETAIL_CHECKOUT_ENDPOINTS_ORDERS = "http://orders.retail-${var.environment}.local:8080"
  }
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
  create_alb         = false
  service_discovery_namespace_id = aws_service_discovery_private_dns_namespace.retail.id
  service_discovery_name         = "orders"
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
  container_port     = 8081
  cpu                = var.app_cpu
  memory             = var.app_memory
  desired_count      = var.app_desired_count
  aws_region         = var.aws_region
  create_alb         = false
}
