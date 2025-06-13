# 1) Pull cluster info so we can configure the Kubernetes provider
data "aws_eks_cluster"      "cluster"      { name = var.cluster_name }
data "aws_eks_cluster_auth" "cluster_auth" { name = var.cluster_name }

# 2) Configure the Kubernetes provider to point at your new EKS API
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.cluster.certificate_authority[0].data
  )
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}


# 3) Your EKS module, switched to use Launch Templates instead of Launch Configurations
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 16.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  # use worker_groups_launch_template so the module creates an AWS Launch Template
  # instead of the deprecated aws_launch_configuration :contentReference[oaicite:0]{index=0}
  worker_groups_launch_template = [
    {
      name                 = "default-workers"
      instance_type        = "t3.medium"
      asg_desired_capacity = 1
      asg_min_size         = 1
      asg_max_size         = 1
    }
  ]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}