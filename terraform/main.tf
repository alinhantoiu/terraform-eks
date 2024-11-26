module "eks" {
  source             = "./modules/eks"
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids
  cluster_name       = var.cluster_name
}

# Use eks-blueprints-addons module in order to install eks add-ons
module "eks_addons" {
  source            = "aws-ia/eks-blueprints-addons/aws"
  version           = "1.19.0"
  cluster_name      = module.eks.eks_cluster_name
  cluster_version   = module.eks.eks_cluster_version
  cluster_endpoint  = module.eks.eks_cluster_endpoint
  oidc_provider_arn = replace(module.eks.oidc_provider_arn, "https://", "")
  enable_karpenter  = true


  eks_addons = {
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
  }

  depends_on = [module.eks]
}