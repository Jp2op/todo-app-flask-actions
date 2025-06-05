provider "aws" {
  region = "us-east-1"
}

# Helm provider configuration to connect to the EKS cluster
# This was added to fix the "invalid configuration" error for Helm
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
  version         = "20.8.4"
  cluster_name    = "flask-todo-cluster"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # EKS control plane ENIs will be in these subnets

  enable_irsa = true

  # --- EKS API Endpoint Access Configuration ---
  # Ensure the public endpoint is enabled and accessible from GitHub Actions runners
  cluster_endpoint_public_access  = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # Allows access from any IP.
  cluster_endpoint_private_access = false

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
  version    = "3.53.1"

  namespace        = "datadog"
  create_namespace = true

  set {
    name  = "datadog.apiKey"
    value = var.datadog_api_key # Ensure this variable is defined (e.g., in variables.tf) and a value is provided
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
    name  = "agents.containerLogs.enabled"
    value = "true"
  }

  set {
    name  = "datadog.env"
    value = "production"
  }

  depends_on = [module.eks]
}