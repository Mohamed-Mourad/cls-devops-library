# Security group for worker nodes (allows EFS access and SSH)
resource "aws_security_group" "worker_sg" {
  name        = "eks-worker-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  # Allow SSH from specified security groups
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

module "vpc" {
  source = "../../modules/vpc"
}

module "eks" {
  source                   = "../../modules/eks"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  worker_security_group_id = aws_security_group.worker_sg.id
}


module "node_group" {
  vpc_id       = module.vpc.vpc_id
  source       = "../../modules/node-group"
  cluster_name = module.eks.eks_cluster_id
  subnet_ids   = module.vpc.private_subnets
  worker_sg_id = aws_security_group.worker_sg.id
}

module "efs" {
  source           = "../../modules/efs"
  efs_name         = "eks-cluster-efs"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnets
  eks_worker_sg_id = aws_security_group.worker_sg.id
  posix_uid        = 1000
  posix_gid        = 1000
}

