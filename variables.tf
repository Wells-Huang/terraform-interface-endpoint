variable "project_name" {
  description = "interface-endpoint-test"
  type        = string
  default     = "production-system"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
