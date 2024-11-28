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

  tags = {
    module = "eks-blueprints-addons"
  }

  depends_on = [module.eks]
}

module "karpenter" {
  source                  = "./modules/karpenter"
  name                    = var.name
  ami_family              = var.ami_family
  ami_id_arm              = var.ami_id_arm
  ami_id_amd64            = var.ami_id_amd64
  private_subnet_ids      = var.private_subnet_ids
  eks_security_group      = module.eks.eks_security_groups
  node_aws_iam_role       = join(",", data.aws_iam_roles.roles.names)
  amd64_limits_cpu        = var.amd64_limits_cpu
  amd64_instance_category = join(",", var.amd64_instance_category)
  arm_limits_cpu          = var.arm_limits_cpu
  arm_instance_category   = join(",", var.arm_instance_category)


  depends_on = [module.eks_addons]
}

data "aws_iam_roles" "roles" {
  name_regex  = "karpenter-eks-sandbox-.*"

  depends_on = [module.eks_addons]
}
