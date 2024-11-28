variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the existing VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
variable "eks_endpoint_access_cidrs" {
  description = "CIDR block(s) allowed to access the EKS API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Default allows public access from anywhere (not recommended for production)
}

# Karpenter variables

variable "name" {
  default = "default"
}

variable "ami_family" {
  default = ""
}

variable "subnet_id" {
  default = ""
}

variable "role" {
  default = ""
}

variable "ami_id" {
  default = ""
}

variable "eks_security_group" {
  description = "Security group ID for EKS control plane"
  type        = string
  default     = ""
}