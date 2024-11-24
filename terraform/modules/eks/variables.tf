variable "vpc_id" {
  description = "The ID of the existing VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "eks_endpoint_access_cidrs" {
  description = "CIDR block(s) allowed to access the EKS API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Default allows public access from anywhere (not recommended for production)
}
