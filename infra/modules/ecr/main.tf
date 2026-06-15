resource "aws_ecr_repository" "this" {
  for_each = toset(var.services)

  name                 = "retail-${each.key}-${var.environment}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    environment = var.environment
    service     = each.key
  }
}
