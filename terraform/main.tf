provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "todo-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24", "10.0.4.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0.0"

  cluster_name    = "todo-cluster"
  cluster_version = "1.29"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  enable_irsa = true

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 3
      min_size     = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  # Add your IAM user mappings here
  map_users = [
    {
      userarn  = "arn:aws:iam::203918885394:user/prefect-worker"
      username = "prefect-worker"
      groups   = ["system:masters"]
    }
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# The module "eks_aws_auth" should be removed.
# module "eks_aws_auth" {
#   source = "terraform-aws-modules/eks/aws//modules/aws-auth"
# 
#   cluster_name = module.eks.cluster_name # This was causing the error
# 
#   aws_auth_users = [ # This structure should be used with map_users in the main EKS module
#     {
#       userarn  = "arn:aws:iam::203918885394:user/prefect-worker"
#       username = "prefect-worker"
#       groups   = ["system:masters"]
#     }
#   ]
# }