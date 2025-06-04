output "debug_api_key" {
  value     = var.datadog_api_key
  sensitive = true
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ap-south-1"
}