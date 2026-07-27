output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "The name of the generated EKS cluster"
  value       = module.eks.cluster_name
}

output "configure_kubectl" {
  description = "Command to update local kubeconfig for the new cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}