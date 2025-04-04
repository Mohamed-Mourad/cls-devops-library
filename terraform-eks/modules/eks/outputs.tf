// Outputs from the EKS module for use in other parts of the CI/CD pipeline.

output "eks_cluster_id" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = aws_eks_cluster.this.endpoint
}

output "eks_cluster_certificate_authority" {
  description = "The base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "eks_cluster_security_group_id" {
  value = aws_security_group.eks_cluster_sg.id
}

output "cluster_oidc_issuer_url" {
  description = "OIDC Issuer URL for IRSA"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_endpoint" {
  description = "EKS Cluster API endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for IRSA"
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
}
