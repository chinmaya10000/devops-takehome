provider "aws" {
  region = var.aws_region
}

# VPC for Cluster
data "aws_availability_zones" "available" {} 
  
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = var.name
  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets  = var.public_subnet_cidr_blocks

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = var.tags
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.name
  kubernetes_version = var.k8s_version

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  # Optional
  endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    initial = {
        instance_types = "t3.medium"
        desired_capacity = 2
        max_capacity     = 3
        min_capacity     = 1
    }
  }

  tags = var.tags

  depends_on = [ module.vpc ]
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # NGINX INGRESS CONTROLLER
  enable_ingress_nginx = true
  ingress_nginx = {
    most_recent = true
    namespace   = "ingress-nginx"

    set = [
      { name = "controller.service.type", value = "LoadBalancer" },
      { name = "controller.service.externalTrafficPolicy", value = "Local" },
      { name = "controller.resources.requests.cpu", value = "100m" },
      { name = "controller.resources.requests.memory", value = "128Mi" },
      { name = "controller.resources.limits.cpu", value = "200m" },
      { name = "controller.resources.limits.memory", value = "256Mi" }
    ]
    set_sensitive = [
      { name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme", value = "internet-facing" },
      { name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type", value = "nlb" },
      { name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type", value = "instance" },
      { name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-path", value = "/healthz" },
      { name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-port", value = "10254" },
      { name = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-health-check-protocol", value = "HTTP" }
    ]
  }

  depends_on = [ module.eks ]
}