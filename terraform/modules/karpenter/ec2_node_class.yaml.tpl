apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: ${name}
spec:
  amiFamily: ${ami_family}
  securityGroupSelectorTerms:
    - id: ${eks_security_group}
  role: "test"
  amiSelectorTerms:
    - id: ${ami_id}
  subnetSelectorTerms:
  %{ for subnet_id in private_subnet_ids ~}
    - id: ${subnet_id}
  %{ endfor ~}