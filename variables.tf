variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "image_uri" {
  description = "Full container image URI to deploy"
  type        = string
  default     = "699938055022.dkr.ecr.us-east-1.amazonaws.com/my-leaderboard-backend:latest"
}