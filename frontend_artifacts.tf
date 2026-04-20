data "aws_caller_identity" "current" {}

locals {
  frontend_artifact_bucket_name = var.frontend_artifact_bucket_name != "" ? var.frontend_artifact_bucket_name : "${var.project_name}-frontend-artifacts-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
}

resource "aws_s3_bucket" "frontend_artifacts" {
  bucket        = local.frontend_artifact_bucket_name
  force_destroy = var.frontend_artifact_bucket_force_destroy

  tags = {
    Name = "${var.project_name}-frontend-artifacts"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_artifacts" {
  bucket = aws_s3_bucket.frontend_artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "frontend_artifacts" {
  bucket = aws_s3_bucket.frontend_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role_policy" "frontend_s3_read" {
  name = "${var.project_name}-frontend-s3-read"
  role = aws_iam_role.frontend_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.frontend_artifacts.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.frontend_artifacts.arn}/*"
      }
    ]
  })
}
