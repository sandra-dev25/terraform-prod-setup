resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project}-${var.environment}-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}