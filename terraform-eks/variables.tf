variable "aws_region" {
  type        = string
  description = "AWS Region for infrastructure provisioning"
  default     = "us-west-2"  # Oregon Region
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "mern-devsecops-cluster"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster"
  default     = "1.30"
}