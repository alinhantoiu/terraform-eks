apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: ${name}-arm
spec:
  amiFamily: ${ami_family}
  securityGroupSelectorTerms:
    - id: ${eks_security_group}
  role: ${node_aws_iam_role}
  amiSelectorTerms:
    - id: ${ami_id_arm}
  subnetSelectorTerms:
  %{ for subnet_id in private_subnet_ids ~}
    - id: ${subnet_id}
  %{ endfor ~}