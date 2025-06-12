# terraform/eks.tf

provider "aws" {
  region = var.region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 16.0"

  # Cluster identity
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Networking (expects a list of subnet IDs)
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  # Worker node groups (legacy syntax)
  worker_groups = [
    {
      name             = "default-workers"
      instance_type    = "t3.medium"
      desired_capacity = 2
      min_size         = 1
      max_size         = 3
    }
  ]

  # Tags for all resources
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
