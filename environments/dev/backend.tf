terraform {
  backend "s3" {
    bucket         = "prod-level-terraform-state-bucket-807"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}