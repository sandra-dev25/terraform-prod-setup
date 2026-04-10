variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Your IP for SSH access"
  type        = string
  default     = "0.0.0.0/0" # ⚠️ change later for security
}