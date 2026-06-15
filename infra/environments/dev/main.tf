module "ecr" {
  source      = "../../modules/ecr"
  environment = var.environment
  services    = ["catalog", "cart", "orders", "checkout", "ui", "admin"]
}
