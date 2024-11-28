output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_cluster_version" {
  value = aws_eks_cluster.main.version
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.main.arn
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

# Output the OIDC provider ARN
output "oidc_provider_arn" {
  value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${aws_eks_cluster.main.identity[0].oidc[0].issuer}"
}
output "eks_security_groups" {
  value = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description = "Security group IDs for the EKS control plane"
}