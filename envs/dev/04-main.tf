data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "${var.project_slug}-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)

  # VPC CIDR /16 -> /20 subnets (newbits=4)
  public_subnets  = [for i, _ in local.azs : cidrsubnet(var.vpc_cidr, 4, i)]
  private_subnets = [for i, _ in local.azs : cidrsubnet(var.vpc_cidr, 4, i + 10)]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.0"

  name = local.name
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Hard requirement: private subnets for nodes + SINGLE NAT gateway
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # Helpful tags for Kubernetes load balancers later (ALB controller, etc.)
  public_subnet_tags = {
    "kubernetes.io/role/elb"              = "1"
    "kubernetes.io/cluster/${local.name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/${local.name}" = "shared"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.15.1"

  name               = local.name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  authentication_mode = "API_AND_CONFIG_MAP"

  # Keep it beginner-friendly so kubectl works from your laptop:
  endpoint_public_access       = true
  endpoint_private_access      = true
  endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Create OIDC provider for IRSA (needed in later stages)
  enable_irsa = true

  # Easiest way to ensure the identity running Terraform can admin the cluster
  enable_cluster_creator_admin_permissions = true

  # Managed EKS add-ons (keeps core components managed)
  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  # Hard requirement: managed node group, AL2023, desired=1 min=1 max=2
  eks_managed_node_groups = {
    main = {
      name = "${local.name}-mng"

      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.node_instance_types

      min_size     = 1
      max_size     = 2
      desired_size = 1

      disk_size = 20

      # ✅ Let EKS manage launch template + bootstrap userdata
      create_launch_template     = false
      use_custom_launch_template = false
    }
  }
}
