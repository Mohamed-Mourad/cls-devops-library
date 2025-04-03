// Outputs from the Node Group module

output "node_group_id" {
  description = "The ID of the EKS node group"
  value       = aws_eks_node_group.this.id
}

output "worker_sg_id" {
  description = "The security group ID for the EKS worker nodes used for remote access"
  value       = var.remote_access_security_group_ids[0]
}
