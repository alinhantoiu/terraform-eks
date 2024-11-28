variable "name" {
  default = ""
}

variable "ami_family" {
  default = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "eks_security_group" {
  description = "Security group ID for EKS control plane"
  type        = string
  default     = ""
}

variable "role" {
  default = ""
}

variable "ami_id" {
  default = ""
}