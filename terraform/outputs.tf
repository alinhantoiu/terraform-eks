output "eks_cluster_endpoint" {
  value = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  value = module.eks.eks_cluster_name
}

output "eks_cluster_version" {
  value = module.eks.eks_cluster_version
}

output "eks_cluster_arn" {
  value = module.eks.eks_cluster_arn
}

output "eks_cluster_certificate" {
  value = module.eks.eks_cluster_certificate_authority
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}
