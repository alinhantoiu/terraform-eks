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

variable "node_aws_iam_role" {
  default = ""
}

variable "ami_id_amd64" {
  default = ""
}

variable "ami_id_arm" {
  default = ""
}

variable "amd64_limits_cpu" {
  default = ""
}

variable "amd64_instance_category" {
  default = ""
}

variable "arm_limits_cpu" {
  default = ""
}

variable "arm_instance_category" {
  default = ""
}