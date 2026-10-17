# Project Context & AI Agent Operating Instructions

> **Project Type**: Demo & Learning Sandbox  
> **Primary Goal**: Hands-on Terraform infrastructure learning with strict cost-awareness and security best practices.

---

## 1. Project Purpose & Philosophy

This repository is an educational and exploratory Terraform workspace designed to demonstrate production-grade cloud network topologies, secure isolation patterns, and Kubernetes infrastructure provisioning on AWS.

Key guiding principles for agents:
1. **Cost Minimization**: All provisioned resources must prioritize the lowest possible cost while maintaining stability. Avoid large instances, redundant multi-NAT setups, or expensive provisioned tiers unless explicitly instructed.
2. **Clear Segmentation**: Strictly respect the network tier design described below. Never compromise isolation for convenience.
3. **Reproducibility & Modularity**: Use modular Terraform definitions and keep configuration code clean, documented, and formatted.

---

## 2. VPC Network Architecture & Subnet Segmentation

The core infrastructure creates a custom VPC with a **three-tier subnet architecture** spread across all available Availability Zones in the target region (default: `eu-north-1`):

```
+-----------------------------------------------------------------------------------+
| AWS VPC (Default: 10.152.0.0/16)                                                 |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  | [1] PUBLIC SUBNETS (DMZ Tier)                                               |  |
|  | - CIDR: var.public_cidr (10.152.0.0/18)                                      |  |
|  | - Route: 0.0.0.0/0 -> Internet Gateway (IGW)                                 |  |
|  | - Purpose: Ingress DMZ, Application Load Balancers (ALB), NAT Gateway        |  |
|  +-----------------------------------------------------------------------------+  |
|                                         | (Outbound via NAT GW)                   |
|  +-----------------------------------------------------------------------------+  |
|  | [2] NAT SUBNETS (Application / Compute Tier)                                |  |
|  | - CIDR: var.nat_cidr (10.152.128.0/18)                                       |  |
|  | - Route: 0.0.0.0/0 -> Single NAT Gateway (in Public Subnet)                  |  |
|  | - Purpose: Application workloads, EKS Worker Nodes, backend compute          |  |
|  |   Needs outbound internet to pull containers/packages without inbound expo   |  |
|  +-----------------------------------------------------------------------------+  |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  | [3] PRIVATE SUBNETS (Isolated Data Tier)                                    |  |
|  | - CIDR: var.private_cidr (10.152.64.0/18)                                    |  |
|  | - Route: Local VPC only (NO route to IGW, NO route to NAT Gateway)           |  |
|  | - Endpoints: VPC Interface Endpoints (SSM, ec2messages, ssmmessages, etc.)   |  |
|  | - Purpose: Critical stateful backend components (e.g., RDS PostgreSQL/MySQL) |  |
|  |   Isolated with zero direct internet access. Patches managed by AWS.         |  |
|  +-----------------------------------------------------------------------------+  |
+-----------------------------------------------------------------------------------+
```

### Detailed Subnet Breakdown & Rules

| Tier | Terraform Resource / Outputs | Internet Access | Target Workloads & Services |
| :--- | :--- | :--- | :--- |
| **Public Subnet (DMZ)** | `aws_subnet.PublicSubnet`<br>`module.vpc.public_subnet_ids` | **Direct Bi-directional** (via Internet Gateway) | Ingress ALBs, Network Load Balancers, Bastion hosts, NAT Gateway allocation. |
| **NAT Subnet (Backend)** | `aws_subnet.NatSubnet`<br>`module.vpc.nat_subnet_ids` | **Outbound Only** (via NAT Gateway) | Application containers, **EKS Worker Nodes**, internal microservices requiring outbound internet access (e.g., pulling container images, external API webhooks). |
| **Private Subnet (Isolated)** | `aws_subnet.PrivateSubnet`<br>`module.vpc.private_subnet_ids` | **Completely Isolated** (No IGW, No NAT) | Databases (**RDS**, Aurora, DocumentDB), Redis/Memcached clusters, internal secure datastores. AWS manages platform patching internally. |

> **IMPORTANT RULE**:
> Never place RDS or critical persistent databases in the public or NAT subnets. They must remain strictly within the isolated `module.vpc.private_subnet_ids`.
> Never place standard EKS worker nodes in the isolated private subnets unless full private image registries and comprehensive VPC endpoints are established; by default, **place EKS nodes in `module.vpc.nat_subnet_ids`**.

---

## 3. EKS Cluster Creation Guidelines

When the user asks to create, configure, or adjust an Amazon EKS cluster:

1. **Target File**: Implement the cluster definition exclusively in [`eks.tf`](./eks.tf).
2. **Reference Documentation**: Refer to [`.agent_instructions/EKS_README.md`](./.agent_instructions/EKS_README.md) for module reference, input variables, and official syntax of the `terraform-aws-modules/eks/aws` module (version `~> 21.29`).
3. **Subnet Placement**:
   - `vpc_id = module.vpc.vpc_id`
   - `subnet_ids = module.vpc.nat_subnet_ids` (Places nodes in NAT-routed subnets for secure internet outbound access)
   - `control_plane_subnet_ids = module.vpc.nat_subnet_ids`

#### Cost Optimization & Node Sizing Recommendations (AWS Free Tier)

> [!IMPORTANT]
> **Free Tier Account Enforcement**: This AWS account strictly enforces Free Tier eligibility. Launching non-eligible instance types will fail with:  
> `InvalidParameterCombination - The specified instance type is not eligible for Free Tier.`

- **Target Node Count**: Keep the cluster minimal — **3 nodes** (e.g., `desired_size = 3`, `min_size = 1`, `max_size = 3`).
- **Free Tier Eligible Instance Type (Required)**:
  - **Instance Type**: `t3.micro` (2 vCPU, 1 GiB Memory) — eligible for 750 hours/month Free Tier in `eu-north-1`.
  - **AMI Type**: `AL2023_x86_64_STANDARD` (x86_64 architecture).
  - **Do NOT use**: `t4g.medium`, `t3.medium`, or other non-free-tier instances on this account, as AutoScaling will fail to launch them.

### Reference EKS Configuration Pattern for `eks.tf`

```hcl
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

  # Permissions
  enable_cluster_creator_admin_permissions = true

  # Core Cluster Addons
  addons = {
    coredns                = {}
    eks-pod-identity-agent = { before_compute = true }
    kube-proxy             = {}
    vpc-cni                = { before_compute = true }
  }

  # Free Tier Eligible Managed Node Group
  eks_managed_node_groups = {
    demo_nodes = {
      # t3.micro is required for AWS Free Tier accounts:
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.micro"]

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
```

---

## 4. File Structure & Conventions

```
terraform_vpc_module/
├── .agent_instructions/
│   └── EKS_README.md       # Upstream reference docs for terraform-aws-modules/eks/aws
├── modules/
│   ├── vpc/                # Core reusable VPC module (subnets, IGW, NAT GW, endpoints)
│   └── ec2/                # Optional EC2 instances module
├── AGENTS.md               # Agent context & instructions (this file)
├── main.tf                 # Terraform & AWS provider configuration
├── variables.tf            # Input variable declarations & regional defaults
├── outputs.tf              # Exported VPC IDs and subnet lists
├── vpc.tf                  # Root module VPC instantiation & moved blocks
├── security_groupd.tf      # Shared security groups (public, NAT, private)
├── iam.tf                  # IAM instance profiles and SSM roles
├── ec-2.tf                 # EC2 test instances (commented out by default)
└── eks.tf                  # EKS cluster module definition (call module here)
```

### Best Practices for Agents Working in this Repository
- **Never delete or break `moved { ... }` blocks** in `vpc.tf`; they preserve state migration from flat resources to the module.
- Always run `terraform fmt` on any modified `.tf` files.
- Verify module outputs before referencing them in downstream resources (e.g., `module.vpc.nat_subnet_ids`, `module.vpc.private_subnet_ids`).
- Maintain existing tags and naming conventions using `${var.product_name}`.
