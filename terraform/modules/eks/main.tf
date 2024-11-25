
### Create EKS cluster ###

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy_attach" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_policy_attach" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.eks_endpoint_access_cidrs
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy_attach]
}

### Enable IAM roles for service accounts ###

data "tls_certificate" "main" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.main.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.main.url
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.main.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.main.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "main" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name               = "eks-sandbox-iam-role"
}

### IAM role for bootstrap node groop ### 

  resource "aws_iam_role" "node_group_role" {
    name = "bootstrap-node-group-role"

    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }]
    })
  }

  resource "aws_iam_role_policy_attachment" "node_group_policies" {
    for_each = toset([
      "AmazonEKSWorkerNodePolicy",
      "AmazonEKS_CNI_Policy",
      "AmazonEC2ContainerRegistryReadOnly",
    ])

    role       = aws_iam_role.node_group_role.name
    policy_arn = "arn:aws:iam::aws:policy/${each.value}"
  }

  ### Create bootstrap node group for karpenter ###

  resource "aws_eks_node_group" "bootstrap" {
    cluster_name    = aws_eks_cluster.main.name
    node_group_name = "bootstrap-node-group"
    node_role_arn   = aws_iam_role.node_group_role.arn
    subnet_ids      = var.private_subnet_ids

    scaling_config {
      desired_size = 1
      min_size     = 1
      max_size     = 1
    }

    instance_types = ["t2.small"]
    capacity_type  = "ON_DEMAND"
    ami_type       = "AL2_x86_64"

    tags = {
      Environment = "terraform-Bootstrap"
    }

    depends_on = [
      aws_iam_role_policy_attachment.node_group_policies,
      aws_eks_cluster.main
    ]

  }