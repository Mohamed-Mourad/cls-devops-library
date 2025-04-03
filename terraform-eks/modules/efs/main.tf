resource "aws_efs_file_system" "this" {
  creation_token   = var.creation_token
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode

  tags = {
    Name = var.efs_name
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "efs-security-group"
  description = "Allow NFS access from EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.eks_worker_sg_id] # Allow from EKS worker nodes
    description     = "Allow EKS workers to access EFS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "efs-security-group"
  }
}

resource "aws_efs_mount_target" "this" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs_sg.id] # Use the new EFS SG
}

resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id

  posix_user {
    uid = var.posix_uid
    gid = var.posix_gid
  }

  root_directory {
    path = "/data"
    creation_info {
      owner_uid   = var.posix_uid
      owner_gid   = var.posix_gid
      permissions = "755"
    }
  }
}
