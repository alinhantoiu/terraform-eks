apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: ${name}-amd64
spec:
  template:
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: [${amd64_instance_category}] 
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["1"]
      nodeClassRef:
        apiVersion: karpenter.k8s.aws/v1beta1
        kind: EC2NodeClass
        name: ${name}-amd64
  limits:
    cpu: ${amd64_limits_cpu}
  disruption:
    consolidationPolicy: WhenUnderutilized
    expireAfter: 720h # 30 * 24h = 720h
