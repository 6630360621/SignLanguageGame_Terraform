output "api_endpoint" {
  description = "Public API base URL through ALB"
  value       = "http://${aws_lb.app.dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint used by ECS tasks"
  value       = aws_db_instance.database.address
}

output "frontend_public_ip" {
  description = "Public IP of frontend EC2 instance"
  value       = aws_instance.frontend.public_ip
}

output "frontend_url" {
  description = "HTTP URL for frontend EC2"
  value       = "http://${aws_instance.frontend.public_dns}"
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.frontend_users.id
}

output "cognito_user_pool_client_id" {
  description = "Cognito App Client ID for frontend"
  value       = aws_cognito_user_pool_client.frontend_app.id
}

output "cognito_hosted_ui_base" {
  description = "Cognito Hosted UI base domain"
  value       = "https://${aws_cognito_user_pool_domain.frontend_domain.domain}.auth.${var.aws_region}.amazoncognito.com"
}

output "frontend_artifact_bucket" {
  description = "S3 bucket where frontend build artifacts are uploaded"
  value       = aws_s3_bucket.frontend_artifacts.bucket
}

output "frontend_artifact_object_key" {
  description = "S3 object key EC2 deploy script expects"
  value       = var.frontend_artifact_object_key
}
