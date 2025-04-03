variable "efs_name" {
  description = "Name tag for the EFS file system"
  type        = string
}

variable "creation_token" {
  description = "EFS creation token"
  type        = string
  default     = "efs-token"
}

variable "performance_mode" {
  description = "EFS performance mode"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "EFS throughput mode"
  type        = string
  default     = "bursting"
}

variable "subnet_ids" {
  description = "List of subnet IDs where EFS mount targets will be created"
  type        = list(string)
}

variable "posix_uid" {
  description = "POSIX UID for EFS access point"
  type        = number
  default     = 1000
}

variable "posix_gid" {
  description = "POSIX GID for EFS access point"
  type        = number
  default     = 1000
}

variable "vpc_id" {
  description = "vpc id"
  type = string
}

variable "eks_worker_sg_id" {
  description = "The security group ID of the EKS worker nodes"
  type        = string
}