module "eks" {
  count   = var.create_eks ? 1 : 0
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.product_name}-eks"
  kubernetes_version = "1.32"

  # Networking
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.nat_subnet_ids
  control_plane_subnet_ids = module.vpc.nat_subnet_ids

  # Endpoint Access
  endpoint_public_access  = true
  endpoint_private_access = true

  # Permissions - Cluster Access Management
  enable_cluster_creator_admin_permissions = true

  # Core Cluster Addons
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  # Cost-optimized Managed Node Group (AWS Graviton ARM64)
  eks_managed_node_groups = {
    demo_nodes = {
      # Graviton2 t4g.medium: ~20% cheaper than t3.medium, superior performance & efficiency
      ami_type       = "AL2023_ARM_64_STANDARD"
      instance_types = ["t4g.medium"]

      min_size     = 1
      desired_size = 3
      max_size     = 3

      capacity_type = "ON_DEMAND"

      tags = merge(var.tags, {
        Role = "worker-node"
      })
    }
  }

  tags = var.tags
}
