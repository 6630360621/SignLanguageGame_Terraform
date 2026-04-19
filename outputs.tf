output "api_endpoint" {
  description = "Public API base URL through ALB"
  value       = "http://${aws_lb.app.dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint used by ECS tasks"
  value       = aws_db_instance.database.address
}
