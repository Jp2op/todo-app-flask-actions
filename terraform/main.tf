provider "aws" {
  region = "us-east-1"
}

# Add this provider "helm" block:
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "flask-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4" # Using EKS module version 20.8.4
  cluster_name    = "flask-todo-cluster"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t3.medium"]
    }
  }
}

resource "helm_release" "datadog" {
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  version    = "3.53.1" # Specifying Datadog chart version

  namespace        = "datadog"
  create_namespace = true

  set {
    name  = "datadog.apiKey"
    value = var.datadog_api_key # Make sure var.datadog_api_key is defined and passed
  }

  set {
    name  = "datadog.site"
    value = "datadoghq.com"
  }

  set {
    name  = "datadog.logs.enabled"
    value = "true"
  }

  set {
    name  = "datadog.apm.enabled"
    value = "true"
  }

  set {
    name  = "datadog.processAgent.enabled"
    value = "true"
  }

  set {
    name  = "agents.containerLogs.enabled" # This is for the Datadog agent configuration
    value = "true"
  }

  set {
    name  = "datadog.env"
    value = "production"
  }

  depends_on = [module.eks] # This is good, ensures EKS is ready
}

# You should also have a variables.tf file (or define variables here) for var.datadog_api_key
# Example:
# variable "datadog_api_key" {
#   description = "Datadog API Key"
#   type        = string
#   sensitive   = true # Recommended for API keys
# }