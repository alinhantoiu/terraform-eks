
resource "null_resource" "apply_ec2_node_class" {
  provisioner "local-exec" {
    command = <<EOT
    echo '${templatefile("${path.module}/ec2_node_class.yaml.tpl", {
      name               = var.name
      ami_family         = var.ami_family
      private_subnet_ids = var.private_subnet_ids
      #subnet_id         = var.subnet_id
      eks_security_group = var.eks_security_group
      #role              = var.role
      ami_id             = var.ami_id
    })}' | KUBECONFIG=./terraform_eks_cluster kubectl apply -f -
    EOT
  }
}