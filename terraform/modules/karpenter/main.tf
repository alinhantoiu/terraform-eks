
# Create nodeclass 

resource "null_resource" "apply_ec2_node_class_arm" {
  provisioner "local-exec" {
    command = <<EOT
    echo '${templatefile("${path.module}/ec2_node_class_arm.yaml.tpl", {
      name               = var.name
      ami_family         = var.ami_family
      private_subnet_ids = var.private_subnet_ids
      eks_security_group = var.eks_security_group
      node_aws_iam_role  = var.node_aws_iam_role
      ami_id_arm         = var.ami_id_arm
    })}' | KUBECONFIG=./terraform_eks_cluster kubectl apply -f -
    EOT
  }
}

resource "null_resource" "apply_ec2_node_class_amd64" {
  provisioner "local-exec" {
    command = <<EOT
    echo '${templatefile("${path.module}/ec2_node_class_amd64.yaml.tpl", {
      name               = var.name
      ami_family         = var.ami_family
      private_subnet_ids = var.private_subnet_ids
      eks_security_group = var.eks_security_group
      node_aws_iam_role  = var.node_aws_iam_role
      ami_id_amd64       = var.ami_id_amd64
    })}' | KUBECONFIG=./terraform_eks_cluster kubectl apply -f -
    EOT
  }
}

# Create nodepool 

resource "null_resource" "apply_ec2_node_pool_amd64" {
  provisioner "local-exec" {
    command = <<EOT
    echo '${templatefile("${path.module}/ec2_node_pool_amd64.yaml.tpl", {
      name                    = var.name
      amd64_limits_cpu        = var.amd64_limits_cpu
      amd64_instance_category = var.amd64_instance_category
    })}' | KUBECONFIG=./terraform_eks_cluster kubectl apply -f -
    EOT
  }
}

resource "null_resource" "apply_ec2_node_pool_arm" {
  provisioner "local-exec" {
    command = <<EOT
    echo '${templatefile("${path.module}/ec2_node_pool_arm.yaml.tpl", {
      name                  = var.name
      arm_limits_cpu        = var.arm_limits_cpu
      arm_instance_category = var.arm_instance_category
    })}' | KUBECONFIG=./terraform_eks_cluster kubectl apply -f -
    EOT
  }
}
