resource "aws_security_group" "eks_node_sg" {
  name   = "eks-node-ssh"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP or allowed CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-node-sg"
  }
}

module "vpc" {
  source = "../../modules/vpc"
}

module "eks" {
  source                   = "../../modules/eks"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  worker_security_group_id = module.node_group.worker_sg_id
}


module "node_group" {
  vpc_id                           = module.vpc.vpc_id
  source                           = "../../modules/node-group"
  cluster_name                     = module.eks.eks_cluster_id
  subnet_ids                       = module.vpc.private_subnets
  remote_access_security_group_ids = [aws_security_group.eks_node_sg.id]
}

module "efs" {
  source           = "../../modules/efs"
  efs_name         = "eks-cluster-efs"
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnets
  eks_worker_sg_id = module.node_group.worker_sg_id
  posix_uid        = 1000
  posix_gid        = 1000
}

