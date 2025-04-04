// This module provisions an EKS Cluster using AWS EKS following the cls-{resource-name} naming scheme.
// It creates an IAM role for the EKS control plane and provisions the cluster within the provided VPC subnets.

# Create an IAM Role for the EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "cls-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "cls-eks-cluster-role"
  }
}

# Attach the AmazonEKSClusterPolicy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Create a Security Group for the EKS cluster control plane communication
resource "aws_security_group" "eks_cluster_sg" {
  name        = "cls-eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  # Allow inboud traffic from worker nodes
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.worker_security_group_id] # Reference worker nodes' SG
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cls-eks-cluster-sg"
  }
}

# Create the EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = "cls-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  version = var.k8s_version

  tags = {
    Name = "cls-eks-cluster"
  }
}

# Create OIDC Provider for IRSA
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
