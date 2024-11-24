### Create NAT gateway ###
# Resource for creating an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain   = "vpc"
}

# Create the NAT Gateway in a public subnet in the existing VPC
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_ids[0]  # Existing public subnet ID

  tags = {
    Name = "terraform-nat-gateway"
  }
}

# Create the route table for private subnets, with the NAT Gateway as the route target
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = {
    Name = "terraform-private-route-table"
  }
}

# Route outbound internet traffic from the private subnet through the NAT Gateway
resource "aws_route" "private_nat_gateway_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Associate the private subnets with the private route table
resource "aws_route_table_association" "private_association" {
  for_each       = toset(var.private_subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}

# Data source to fetch the existing VPC by its ID
data "aws_vpc" "existing" {
  id = var.vpc_id  # Replace this with your VPC ID or fetch dynamically
}

# Data source to fetch the Internet Gateway attached to the VPC using a filter
data "aws_internet_gateway" "existing" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = {
    Name = "terraform-public-route-table"
  }
}

resource "aws_route" "public_igw_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"  # All internet-bound traffic
  gateway_id             = data.aws_internet_gateway.existing.id  # Route to Internet Gateway
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_association" {
  for_each       = toset(var.public_subnet_ids)  # Public subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}


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

    instance_types = ["t2.micro"]
    capacity_type  = "ON_DEMAND"
    ami_type       = "AL2_x86_64"

    tags = {
      Environment = "terraform-Bootstrap"
    }

    depends_on = [
      aws_iam_role_policy_attachment.node_group_policies,
      aws_eks_cluster.main,
      aws_eip.nat,
      aws_nat_gateway.main,
      aws_route_table.private,
      aws_route_table.public
    ]

  }