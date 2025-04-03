// This module provisions an EKS Node Group (worker nodes) using AWS EKS native node group resource.
// It creates an IAM role for the worker nodes and attaches the necessary AWS policies.
// The node group is launched into the specified subnets, typically the private subnets from the VPC module.

# Create an IAM Role for EKS worker nodes
resource "aws_iam_role" "eks_node_role" {
  name = "cls-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "cls-eks-node-role"
  }
}

# Attach the necessary policies to the node IAM role
resource "aws_iam_role_policy_attachment" "worker_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "worker_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "worker_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "efs_access_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess"
  role       = aws_iam_role.eks_node_role.name
}

# Security group for worker nodes (allows EFS access and SSH)
resource "aws_security_group" "worker_sg" {
  name        = "eks-worker-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  # Allow SSH from specified security groups
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = var.remote_access_security_group_ids
  }

  # Allow all outbound traffic (EFS, EKS API, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-worker-sg"
  }
}

# Launch template with custom security group and instance configuration
resource "aws_launch_template" "this" {
  name_prefix   = "eks-worker-"
  instance_type = var.instance_types[0] # Use first instance type from list
  key_name      = var.ec2_ssh_key

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.disk_size
      volume_type = "gp2"
    }
  }

  vpc_security_group_ids = [aws_security_group.worker_sg.id]
}

# Create the EKS Node Group using the launch template
resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = "cls-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids
  ami_type        = var.ami_type

  scaling_config {
    desired_size = var.desired_capacity
    min_size     = var.min_size
    max_size     = var.max_size
  }

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  tags = merge({
    Name = "cls-eks-node-group"
  }, var.extra_tags)
}