locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  ssm_endpoints = [
    "com.amazonaws.ap-northeast-1.ssm",
    "com.amazonaws.ap-northeast-1.ec2messages",
    "com.amazonaws.ap-northeast-1.ssmmessages"
  ]
}
