output "vpc_id" {
  description = "VPC ID from VPC module"
  value       = module.vpc.vpc_id
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = module.eks.eks_cluster_endpoint
}

output "efs_file_system_id" {
  value = module.efs.file_system_id
}

output "efs_access_point_id" {
  value = module.efs.access_point_id
}
